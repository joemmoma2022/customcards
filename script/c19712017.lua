--Battle Planning
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Choose 1 card from your Deck and place it on top
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Ensure there is at least 1 card in the Deck
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end

-- Let player choose a card from the Deck and move it to the top (no shuffle)
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
    if #g==0 then return end
    Duel.ConfirmCards(tp,g) -- Reveal entire Deck to player
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local tg=g:Select(tp,1,1,nil):GetFirst()
    if tg then
        Duel.DisableShuffleCheck()
        Duel.MoveSequence(tg,0) -- Move selected card to top of Deck (index 0)
    end
end
