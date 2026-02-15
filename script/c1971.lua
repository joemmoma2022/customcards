local s,id=GetID()
function s.initial_effect(c)
	-- Activate skill
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
		s.doubleDamageRegistered = false

		-- Track LP loss continuously
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

-- Track LP lost for each player
function s.checkop()
	for tp=0,1 do
		local current_lp=Duel.GetLP(tp)
		if not s[tp] then s[tp]=current_lp end
		if s[tp]>current_lp then
			s[2+tp]=s[2+tp]+(s[tp]-current_lp)
			s[tp]=current_lp
		elseif s[tp]<current_lp then
			s[tp]=current_lp
		end
	end
end

-- Flip condition: Your Draw Phase, lost 8000+ LP, double damage not activated yet
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
		and Duel.GetTurnPlayer()==tp
		and Duel.GetCurrentPhase()==PHASE_DRAW
		and s[2+tp]>=8000
		and not s.doubleDamageRegistered
end

-- Flip operation: activate double damage effect for opponent for the rest of the duel
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)

		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1) -- opponent takes double damage
		e1:SetValue(s.damval)
		e1:SetReset(0)  -- persists entire duel

		Duel.RegisterEffect(e1,tp)

		s.doubleDamageRegistered = true
	end
end

function s.damval(e,re,val,r,rp,rc)
	return val*2
end
