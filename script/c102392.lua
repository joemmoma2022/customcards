-- Gain 2000 LP on Flip
-- Skill
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	-- Startup
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
	-- Flip at first draw phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function()
		return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	end)
	e1:SetOperation(s.flipop)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()

	-- Gain 2000 LP when this Skill is flipped face-up
	Duel.Recover(tp,2000,REASON_EFFECT)
end
