local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Filter for opponent's face-up monsters
function s.filter(c)
    return c:IsFaceup() and c:IsCanAddCounter(0x1015,1)
end

--Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        tc:AddCounter(0x1015,1)
        Duel.Damage(1-tp,300,REASON_EFFECT)
    end
    -- Banish this card after resolution
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
