local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand and add up to 15 named cards from outside the duel
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

--Target: always possible
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

--Activate: name up to 15 cards and add them from outside the duel
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local named_codes = {}
    local count = 0
    while count < 15 do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
        local code = Duel.AnnounceCard(tp)
        if code == 0 then break end -- 0 = player stops naming
        table.insert(named_codes, code)
        count = count + 1
        -- Optional: ask if player wants to continue
        if count < 15 and not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            break
        end
    end

    for _,code in ipairs(named_codes) do
        local token=Duel.CreateToken(tp,code)
        if token then
            Duel.SendtoHand(token,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,token)
        end
    end

    -- Banish this card face-down after resolution
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
