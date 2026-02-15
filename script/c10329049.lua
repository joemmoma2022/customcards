--Ice Lock
local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
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

--Filter: face-up opponent monsters that can be targeted by this effect
function s.filter(c,e)
    return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

--Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        -- Cannot attack
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)

        -- Cannot change battle position
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e2)
    end

    -- Banish this card after resolution
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
