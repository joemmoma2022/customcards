local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1329)
    c:SetUniqueOnField(1,0,id)
    c:EnableReviveLimit()

    -- Must be Special Summoned by "Masked HERO - Traveler"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(function(e,se,sp,st)
        return se and se:GetHandler():IsCode(19712009) -- Masked HERO - Traveler
    end)
    c:RegisterEffect(e0)

    -- On summon: add 1 Exceed Charge counter
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(s.addcounter)
    c:RegisterEffect(e1)
    local e1x=e1:Clone()
    e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1x)

    -- Quick Effect: Remove 1 counter; destroy 1 opponent monster and inflict damage equal to half its ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.qecond)
    e2:SetCost(s.qecost)
    e2:SetTarget(s.qetg)
    e2:SetOperation(s.qeop)
    c:RegisterEffect(e2)
end

-- Add 1 Exceed Charge counter on summon
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() then
        c:AddCounter(0x1329,1)
    end
end

-- Quick effect condition: must have at least 1 counter
function s.qecond(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1329)>0
end

-- Cost: remove 1 counter
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsCanRemoveCounter(tp,0x1329,1,REASON_COST) end
    c:RemoveCounter(tp,0x1329,1,REASON_COST)
end

-- Target 1 opponent monster
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) -- Damage calculated on resolution
end

-- Destroy and inflict damage = half ATK
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local atk=math.floor(tc:GetAttack()/2)
        if Duel.Destroy(tc,REASON_EFFECT)>0 and atk>0 then
            Duel.Damage(1-tp,atk,REASON_EFFECT)
        end
    end
end
