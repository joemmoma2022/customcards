local s,id=GetID()
local BACKSTAB_ID=19712036
local STRIKE_ARC=0x0801

function s.initial_effect(c)
    -- Quick effect: When opponent activates a "Strike" card on the field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Condition: Opponent activates a "Strike" card on the field
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return ep==1-tp and rc:IsOnField() and rc:IsSetCard(STRIKE_ARC)
end

-- Filter to find "Backstab" card in deck
function s.filter(c)
    return c:IsCode(BACKSTAB_ID) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
        Duel.ConfirmCards(1-tp,g)
        local opp=Duel.GetTurnPlayer()

        -- Skip all opponent's remaining phases this turn
        Duel.SkipPhase(opp, PHASE_DRAW,    RESET_PHASE+PHASE_END, 1)
        Duel.SkipPhase(opp, PHASE_STANDBY, RESET_PHASE+PHASE_END, 1)
        Duel.SkipPhase(opp, PHASE_MAIN1,   RESET_PHASE+PHASE_END, 1)
        Duel.SkipPhase(opp, PHASE_BATTLE,  RESET_PHASE+PHASE_END, 1, 1)
        Duel.SkipPhase(opp, PHASE_MAIN2,   RESET_PHASE+PHASE_END, 1)
        Duel.SkipPhase(opp, PHASE_END,     RESET_PHASE+PHASE_END, 1)

        -- No skip for your Standby Phase; duel resumes normally on your Draw Phase
    end
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
    end
end
