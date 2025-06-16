-- Speedroid Synchro Surge / Hi-Speedroid Warrior Tridoron
-- ID: 19712871
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters (both must be Speedroids)
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2016),1,1,
        Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,0x2016)),1,99)
    c:EnableReviveLimit()

    -- Enable Wheel counters on this card
    c:EnableCounterPermit(0x1999)

    -- This card's attribute is also considered WIND
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetValue(ATTRIBUTE_WIND)
    c:RegisterEffect(e0)

    -- Gain 500 ATK per Speedroid monster in your GY if Special Summoned by "Speedroid: Type Speed!"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Add 1 "Wheel" counter at your End Phase, max 1
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return Duel.GetTurnPlayer()==tp
    end)
    e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return e:GetHandler():GetCounter(0x1999)<1 end
        Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
    end)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetCounter(0x1999)<1 then
            c:AddCounter(0x1999,1)
        end
    end)
    c:RegisterEffect(e2)

    -- Quick effect: Remove 1 Wheel counter to gain 500 ATK per WIND Machine/Dragon in your GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.atkcost)
    e3:SetOperation(s.atkop2)
    c:RegisterEffect(e3)
end

-- Was Special Summoned by effect of "Speedroid: Type Speed!"
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
        and re and re:GetHandler()
        and re:GetHandler():IsCode(19712872)
end

-- Gain 500 ATK per Speedroid monster in your GY
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=Duel.GetMatchingGroupCount(
        function(card) return card:IsSetCard(0x2016) and card:IsType(TYPE_MONSTER) end,
        tp,LOCATION_GRAVE,0,nil)
    if ct>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Remove 1 Wheel counter as cost
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetCounter(0x1999)>0 end
    c:RemoveCounter(tp,0x1999,1,REASON_COST)
end

-- Gain 500 ATK per WIND Machine/Dragon in your GY
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(card)
        return (card:IsRace(RACE_MACHINE) or card:IsRace(RACE_DRAGON))
            and card:IsAttribute(ATTRIBUTE_WIND)
            and card:IsLocation(LOCATION_GRAVE)
            and card:IsControler(tp)
    end,tp,LOCATION_GRAVE,0,nil)
    local atkval=g:GetCount()*500
    if atkval>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atkval)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
