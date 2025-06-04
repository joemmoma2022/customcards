--Custom Gem-Knight Fusion (Contact Fusion Version)
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Material: Gem-Knight Citrine + Pyro-Type
    Fusion.AddProcMix(c,true,true,67985943,aux.FilterBoolFunction(Card.IsRace,RACE_PYRO))
    --Contact Fusion (like Alba-Lenatus)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
    --Burn during your Standby Phase only
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return Duel.GetTurnPlayer()==tp
    end)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
    --Attack boost during damage calculation
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    --Revive Gem-Knight Citrine
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

--Contact Fusion Settings
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

function s.contactfilter(c,tp)
    return (c:IsFaceup() or c:IsControler(tp)) and c:IsAbleToGraveAsCost()
        and (c:IsCode(67985943) or c:IsRace(RACE_PYRO))
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,0,nil,tp)
end

function s.contactop(g)
    Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL+REASON_FUSION)
end

--Burn target selection
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
--Burn operation (only on your Standby Phase)
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer() == tp then
        Duel.Damage(1-tp,500,REASON_EFFECT)
    end
end

--ATK Boost during Damage Calculation
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return c:IsRelateToBattle() and c:IsSummonType(SUMMON_TYPE_FUSION) and a and d and a==c
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if bc then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(bc:GetAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
    end
end

--Revive Gem-Knight Citrine
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.spfilter(c,e,tp)
    return c:IsCode(67985943) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
    end
end
