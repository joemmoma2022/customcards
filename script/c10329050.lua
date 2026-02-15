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

--Filter: face-up opponent monsters
function s.filter(c)
    return c:IsFaceup()
end

--Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
end

--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Enable Ice Spike Counter on target monster
        tc:EnableCounterPermit(0x8980)

        -- Add 1 Ice Spike Counter
        tc:AddCounter(0x8980,1)

        -- Cannot attack
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e1)

        -- Cannot change battle position
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e2)

        -- Cannot be Tributed
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UNRELEASABLE_SUM)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetValue(1)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e3)

        local e4=e3:Clone()
        e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
        tc:RegisterEffect(e4)

        -- End Phase: opponent takes 500 damage while monster has Ice Spike Counter
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_PHASE+PHASE_END)
        e5:SetCountLimit(1)
        e5:SetLabelObject(tc) -- store the monster in the effect

        -- Condition: monster is face-up and has counter
        e5:SetCondition(function(ef,tp)
            local m=ef:GetLabelObject()
            return m and m:IsFaceup() and m:GetCounter(0x8980)>0
        end)

        -- Operation: inflict 500 damage
        e5:SetOperation(function(ef,tp)
            local m=ef:GetLabelObject()
            if m and m:IsFaceup() and m:GetCounter(0x8980)>0 then
                Duel.Damage(1-tp,500,REASON_EFFECT)
            end
        end)

        Duel.RegisterEffect(e5,tp)
    end

    -- Banish this Spell after resolution
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
