local s,id=GetID()
local WORM_SPEED_ID=19712874

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Trigger once at the beginning of the Duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f) -- Skill Zone
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Set only the user's LP to 8000
	Duel.SetLP(tp,8000)

	-- Optional: generate token or startup bonus
	-- local token=Duel.CreateToken(tp,WORM_SPEED_ID)
	-- Duel.SendtoHand(token,tp,REASON_RULE)
	-- Duel.ConfirmCards(1-tp,token)
end

function s.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.GetFlagEffect(tp,id)<2
		and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_HAND,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_COST)~=0 then
		local token=Duel.CreateToken(tp,WORM_SPEED_ID)
		Duel.SendtoHand(token,tp,REASON_RULE)
		Duel.ConfirmCards(1-tp,token)
		Duel.RegisterFlagEffect(tp,id,0,0,1)
	end
end
