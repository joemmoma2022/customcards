--Custom Gem-Knight Fusion
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1319) -- "Inferno" counter

    --Alternative Fusion Summon procedure
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.sprcon)
    e0:SetOperation(s.sprop)
    c:RegisterEffect(e0)

    --Gain ATK equal to opponent's DEF at the start of battle
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    --Add 1 Inferno counter on battle destroy
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetOperation(s.ctrop)
    c:RegisterEffect(e2)

    --Indestructible by battle if 3+ Inferno counters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    --Quick Effect: Destroy and burn if 3+ counters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.qecon)
    e4:SetCost(s.qecost)
    e4:SetTarget(s.qetg)
    e4:SetOperation(s.qeop)
    c:RegisterEffect(e4)
end

--Fusion Materials: Gem-Knight Crystal + 1 Pyro
function s.sprfilter1(c)
    return c:IsCode(76908448) and c:IsAbleToGraveAsCost()
end
function s.sprfilter2(c)
    return c:IsRace(RACE_PYRO) and c:IsAbleToGraveAsCost()
end
function s.sprcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.sprfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.sprfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.sprfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_COST)
end

--ATK gain based on opponent's DEF at battle start
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsFaceup() and bc:GetDefense()>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if not bc or not bc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
    local def=bc:GetDefense()
    if def<0 then def=0 end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(def)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

--Add Inferno counter on battle destruction
function s.ctrop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToBattle() then
        c:AddCounter(0x1319,1)
    end
end

--Battle indestructible with 3+ counters
function s.indcon(e)
    return e:GetHandler():GetCounter(0x1319)>=3
end

--Quick Effect: destroy 1 opponent monster and burn 1000
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1319)>=3
end
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsCanRemoveCounter(tp,0x1319,1,REASON_COST) end
    c:RemoveCounter(tp,0x1319,1,REASON_COST)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    end
end
