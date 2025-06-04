local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x27),1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,0x27)),1,99)
    c:EnableReviveLimit()

    --Add Counters on Synchro Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.ctcon)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    --Activate Effect: Remove Counter
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)

    --Increase ATK by 500 for each counter
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    -- Add WATER attribute
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_ADD_ATTRIBUTE)
    e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
    e4:SetValue(ATTRIBUTE_WATER)
    c:RegisterEffect(e4)

    -- Add Machine type
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_ADD_RACE)
    e5:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
    e5:SetValue(RACE_MACHINE)
    c:RegisterEffect(e5)
end

-- Condition: Synchro Summoned
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Operation: Add 1 Rabbit and 1 Tank Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:AddCounter(0x111f,1) -- Rabbit counter
    c:AddCounter(0x1120,1) -- Tank counter
end

-- Calculate ATK increase: 500 per counter
function s.atkval(e,c)
    return (c:GetCounter(0x111f) + c:GetCounter(0x1120)) * 500
end

-- Operation: Remove a counter for effect
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local b1=c:IsCanRemoveCounter(tp,0x111f,1,REASON_COST)
    local b2=c:IsCanRemoveCounter(tp,0x1120,1,REASON_COST)
    if not b1 and not b2 then return end
    local sel=0
    if b1 and b2 then
        sel=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif b1 then
        sel=0
    else
        sel=1
    end
    if sel==0 then
        -- Rabbit effect
        c:RemoveCounter(tp,0x111f,1,REASON_COST)
        local ct=#c:GetMaterial()
        if ct>2 then ct=2 end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,0,nil,e,0,tp,false,false)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,ct,nil)
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    else
        -- Tank effect
        c:RemoveCounter(tp,0x1120,1,REASON_COST)
        local ct=#c:GetMaterial()
        if ct>2 then ct=2 end
        local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local sg=g:Select(tp,1,ct,nil)
            Duel.SendtoGrave(sg,REASON_EFFECT)
        end
    end
end
