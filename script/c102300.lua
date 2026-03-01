local s,id=GetID()

local SET_LP_SELF = 25000

function s.initial_effect(c)
	-- Auto trigger Turn 1 Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==1
		and Duel.GetCurrentChain()==0
		and Duel.GetFlagEffect(tp,id)==0
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Ensure it only happens once
	Duel.RegisterFlagEffect(tp,id,0,0,0)

	-- Set the activating player's LP
	Duel.SetLP(tp,SET_LP_SELF)

	-- Banish this card face-down from wherever it is
	Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
end









