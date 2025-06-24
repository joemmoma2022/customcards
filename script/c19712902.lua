-- Skip Turn Surge (modified)
local s,id=GetID()
function s.initial_effect(c)
	-- Activate during opponent's turn to skip their turn and skip your next Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- You cannot conduct your next Battle Phase after activation
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1b:SetCode(EFFECT_CANNOT_BP)
	e1b:SetTargetRange(1,0)
	e1b:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2) -- disables your next Battle Phase only
	e1b:SetCondition(s.bpcon)
	e1b:SetLabelObject(e1)
	c:RegisterEffect(e1b)

	-- Redirect to banish when sent to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_ACTIVATED) end)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

	-- GY effect: Banish to search a "Change" card (Once per Duel)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- Only activate during opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Skip opponent's entire turn, duel resumes on your Standby Phase
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=Duel.GetTurnPlayer()
	-- Skip opponent's phases this turn
	Duel.SkipPhase(opp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(opp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(opp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(opp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(opp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(opp,PHASE_END,RESET_PHASE+PHASE_END,1)
	-- Register flag for skipping your next Battle Phase
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2)
end

-- Condition for your next Battle Phase skip
function s.bpcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end

-- Cost: Banish this card from your GY
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Target a "Change" card in Deck
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Add it to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Filter: any "Change" card (SetCard 0xa5)
function s.thfilter(c)
	return c:IsSetCard(0xa5) and c:IsAbleToHand()
end
