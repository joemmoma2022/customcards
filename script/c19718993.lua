-- Noble Justice and Vengeance
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop)
end

-- Skill Activation: Start of Duel
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount() == 1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add "Risen Noble Knight of Vengeance Ixa" to Extra Deck
	local risen=Duel.CreateToken(tp,19712844)
	if risen then
		local g1=Group.CreateGroup()
		g1:AddCard(risen)
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Add "Noble Knight of Justice Ixa" to hand
	local justice=Duel.CreateToken(tp,19712845)
	if justice then
		Duel.SendtoHand(justice,nil,REASON_RULE)
	end

	-- Halved battle damage if Risen is not on the field
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.halve_damage)
	Duel.RegisterEffect(e1,tp)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetCondition(s.no_effect_damage)
	Duel.RegisterEffect(e2,tp)

	-- Trigger effect on Risen's Special Summon
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.on_risen_summon)
	Duel.RegisterEffect(e3,tp)

	-- Double battle damage involving Risen
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.double_dmg_target)
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	Duel.RegisterEffect(e4,tp)
end

-- Check if Risen is not on field → halve damage
function s.halve_damage(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_BATTLE)~=0 and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,19712844) then
		return math.floor(val/2)
	end
	return val
end

function s.no_effect_damage(e,tp,eg,ep,ev,re,r,rp)
	return false
end

-- On Special Summon of Risen → Destroy All + Burn + No attacks
function s.on_risen_summon(e,tp,eg,ep,ev,re,r,rp)
	for sc in aux.Next(eg) do
		if sc:IsCode(19712844) and sc:IsSummonType(SUMMON_TYPE_SPECIAL) then
			Duel.Hint(HINT_CARD,tp,id)
			local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			local count=g:GetCount()
			if count>0 then
				Duel.Destroy(g,REASON_EFFECT)
				Duel.Damage(tp,count*100,REASON_EFFECT)
				Duel.Damage(1-tp,count*100,REASON_EFFECT)
			end
			-- Cannot attack this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetProperty(EFFECT_FLAG_OATH)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

-- Battle damage involving Risen is doubled
function s.double_dmg_target(e,c)
	return c:IsCode(19712844)
end
