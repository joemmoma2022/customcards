local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand and add 1 named card from outside the duel
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Target: always possible, just used to set info
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

--Activate: name a card and add it from outside the duel
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local code=Duel.AnnounceCard(tp) -- player names a card by code
    local token=Duel.CreateToken(tp,code)
    if token then
        Duel.SendtoHand(token,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,token)
    end

    -- Banish this card face-down after resolution
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
