local s,id=GetID()
local MANTIS_BABY_TOKEN_ID=511009033

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Special Summon by tributing 2 Insect monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- MATERIAL_CHECK to sum tributed monsters' printed ATK
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_MATERIAL_CHECK)
    e4:SetValue(s.valcheck)
    c:RegisterEffect(e4)

    -- SUMMON_COST triggers MATERIAL_CHECK effect
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_SUMMON_COST)
    e5:SetOperation(s.facechk)
    e5:SetLabelObject(e4)
    c:RegisterEffect(e5)

    -- Quick Effect: Banish 1 Insect in GY; gain its ATK until end phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Indestructible while Mantis Baby Token exists
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    local e6=e3:Clone()
    e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e6)
end

-- Special Summon condition: Tribute 2 Insect monsters
function s.spfilter(c)
    return c:IsRace(RACE_INSECT) and (c:IsReleasable() or c:IsType(TYPE_TOKEN))
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
    return #g>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
end

-- Special Summon operation: Tribute 2 Insects
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,2,2,nil)
    c:SetMaterial(g)
    Duel.Release(g,REASON_COST)
end

-- MATERIAL_CHECK to sum tributed monsters' printed ATK and apply to this card
function s.valcheck(e,c)
    local g=c:GetMaterial()
    local atk=0
    for tc in aux.Next(g) do
        local catk=tc:GetTextAttack()
        atk = atk + (catk >= 0 and catk or 0)
    end
    if e:GetLabel()==1 then
        e:SetLabel(0)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
        c:RegisterEffect(e1)
    end
end

-- SUMMON_COST triggers MATERIAL_CHECK label for valcheck to apply the ATK boost
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
    e:GetLabelObject():SetLabel(1)
end

-- Quick Effect: Banish 1 Insect monster from GY, gain its ATK until end phase
function s.gyfilter(c)
    return c:IsRace(RACE_INSECT) and c:GetAttack()>0 and c:IsAbleToRemove()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        e:SetLabel(g:GetFirst():GetAttack())
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local val=e:GetLabel()
    if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- Indestructibility condition: If any Mantis Baby Token is on the field
function s.indcon(e)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(MANTIS_BABY_TOKEN_ID) and c:IsFaceup()
    end, e:GetHandlerPlayer(), LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end
