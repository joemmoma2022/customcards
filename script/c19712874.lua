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

-- Only during opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opp=Duel.GetTurnPlayer()

	-- Skip phases up to End Phase
	Duel.SkipPhase(opp, PHASE_DRAW,    RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_STANDBY, RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_MAIN1,   RESET_PHASE+PHASE_END, 1)
	Duel.SkipPhase(opp, PHASE_BATTLE,  RESET_PHASE+PHASE_END, 1, 1)
	Duel.SkipPhase(opp, PHASE_MAIN2,   RESET_PHASE+PHASE_END, 1)
	-- DO NOT skip PHASE_END


	-- Draw 2 cards instead of 1 on your next Draw Phase
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	e2:SetValue(2)
	Duel.RegisterEffect(e2,tp)
end
