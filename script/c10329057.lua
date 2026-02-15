local s,id=GetID()
function s.initial_effect(c)
    --Negate Spell/Trap and add to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Condition: opponent activates Spell/Trap that can be negated
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

--Target: the card being activated
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end

--Operation: negate and add to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) then
        if rc:IsRelateToEffect(re) then
            Duel.SendtoHand(rc,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,rc)
        end
    end
    -- Banish this card face-down
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
