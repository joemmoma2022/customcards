-- Skill: Take Control Transformation
-- ID placeholder: Replace with your assigned Skill ID
local s,id=GetID()

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Flip this Skill at the start of the duel
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.GetFlagEffect(tp,id)<2
		and Duel.IsExistingMatchingCard(Card.IsControler, tp, 0, LOCATION_MZONE, 1, nil, 1-tp)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsControler,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	local tc=g:GetFirst()
	if not tc then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local race=Duel.AnnounceRace(tp,1,RACE_ALL)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,12)

	if Duel.GetControl(tc,tp)~=0 then
		local ogcode=tc:GetOriginalCode()
		-- Change Type
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

		-- Change Level
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(lv)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)

		-- Return control at End Phase
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetCondition(function(e) return tc and tc:IsControler(tp) end)
		e3:SetOperation(function(e)
			if tc and Duel.GetControl(tc,1-tp)>0 then
				tc:ResetEffect(EFFECT_CHANGE_RACE,RESET_EVENT+RESETS_STANDARD)
				tc:ResetEffect(EFFECT_CHANGE_LEVEL,RESET_EVENT+RESETS_STANDARD)
			end
			e:Reset()
		end)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end

	Duel.RegisterFlagEffect(tp,id,0,0,1)
end
