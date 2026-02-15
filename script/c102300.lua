-- Equalizer Protocol
-- Auto-Start Spell (Self LP Only)
local s,id=GetID()

local SET_LP_SELF = 4000  -- LP you will be set to

function s.initial_effect(c)
	-- Startup trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	-- Fire at first draw phase (Turn 1) - ONCE
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function(e,tp)
		return Duel.GetCurrentChain()==0
			and Duel.GetTurnCount()==1
			and Duel.GetFlagEffect(tp,id)==0
	end)
	e1:SetOperation(s.activate)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Mark as used so it only resolves once
	Duel.RegisterFlagEffect(tp,id,0,0,0)

	-- If this card started in hand, draw 1
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp,1,REASON_EFFECT)
	end

	-- Set ONLY the activating player's LP
	Duel.SetLP(tp,SET_LP_SELF)

	-- Banish face-down after resolution
	Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
end
