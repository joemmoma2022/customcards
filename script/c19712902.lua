--Skip Turn Surge
local s,id=GetID()
function s.initial_effect(c)
	-- Activate during opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Banish instead of sending to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_ACTIVATED) end)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end

-- Only activate during opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=Duel.GetTurnPlayer()

	-- Skip all opponent phases to end their turn
	Duel.SkipPhase(opp, PHASE_DRAW,    RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_STANDBY, RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_MAIN1,   RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_BATTLE,  RESET_PHASE+PHASE_END, 1, 1)
	Duel.SkipPhase(opp, PHASE_MAIN2,   RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_END,     RESET_PHASE+PHASE_END, 1)

	-- Lock next Standby Phase to carry a search effect
	local turn_id=Duel.GetTurnCount()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(function(e) return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>turn_id end)
	e1:SetOperation(s.searchop)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end

-- Search for "Change" card from Deck
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xa5) and c:IsAbleToHand()
end
