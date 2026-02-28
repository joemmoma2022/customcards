--Mercury Spike
local s,id=GetID()

function s.initial_effect(c)
    --Activate from hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- UPDATED COUNTER ID
s.counter_list={0x8830}

function s.filter(c)
    return c:IsFaceup()
end

--Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x8830,1)
end

--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end

    -- Allow counter placement
    tc:EnableCounterPermit(0x8830)

    -- Add counter
    tc:AddCounter(0x8830,1)

    -- Register dynamic reduction effect ONCE
    if tc:GetFlagEffect(id)==0 then
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(s.atkval)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end

    -- Burn damage = 250 × counters
    local ct=tc:GetCounter(0x8830)
    if ct>0 then
        Duel.Damage(1-tp,ct*250,REASON_EFFECT)
    end

    -- Banish this card
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end

-- Dynamic ATK/DEF reduction
function s.atkval(e,c)
    return -c:GetCounter(0x8830)*250
end