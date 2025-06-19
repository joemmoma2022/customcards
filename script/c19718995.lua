local s,id=GetID()

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,nil,nil)

	-- Startup operation: add cards and place Sanctuary, then register passives globally
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Hyperion to Extra Deck
	local hyperion=Duel.CreateToken(tp,19712864)
	Duel.SendtoDeck(hyperion,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Agent of Hope - Live to hand
	local live=Duel.CreateToken(tp,19712867)
	Duel.SendtoHand(live,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,live)

	-- Place Sanctuary face-up in Field Zone
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,nil,56433456)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end

	-- Register passive effects globally AFTER Sanctuary is placed
	if tp~=nil then
		-- ATK boost for Hyperion per Fairy banished
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.atktg)
		e2:SetCondition(s.atkcon)
		e2:SetValue(s.atkval)
		Duel.RegisterEffect(e2,tp)

		-- Sanctuary indestructible by effects once per turn
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetTargetRange(LOCATION_FZONE,0)
		e3:SetCondition(s.sanctuarycon)
		e3:SetValue(s.indestructableval)
		Duel.RegisterEffect(e3,tp)

		-- Reset indestructible flag at start of each turn
		local e_reset=Effect.CreateEffect(e:GetHandler())
		e_reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e_reset:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e_reset:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e_reset:SetOperation(s.resetflag)
		Duel.RegisterEffect(e_reset,tp)

		-- Destroy DARK monsters you control or summon
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
		e4:SetCondition(s.darkdescon)
		e4:SetOperation(s.darkdesop)
		Duel.RegisterEffect(e4,tp)

		local e5=e4:Clone()
		e5:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(e5,tp)

		-- Destroy DARK monster attacked by Hyperion before damage calculation
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e6:SetCode(EVENT_ATTACK_ANNOUNCE)
		e6:SetCondition(s.descon)
		e6:SetOperation(s.desop)
		Duel.RegisterEffect(e6,tp)
	end
end

function s.controlcheck(tp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19712864)
	   and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,56433456)
end

function s.atktg(e,c)
	return c:IsCode(19712864)
end

function s.atkcon(e)
	return s.controlcheck(e:GetHandlerPlayer())
end

function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_FAIRY)*1000
end

function s.sanctuarycon(e)
	local tp=e:GetHandlerPlayer()
	return s.controlcheck(tp) and Duel.GetFlagEffect(tp,id)==0
end

function s.indestructableval(e,re,r,rp)
	local tp=e:GetHandlerPlayer()
	if Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return true
	end
	return false
end

function s.resetflag(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
end

function s.darkdescon(e,tp,eg,ep,ev,re,r,rp)
	if not s.controlcheck(tp) then return false end
	return eg:IsExists(function(c) return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) end,1,nil)
end

function s.darkdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c) return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) end,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	if not def or not at then return false end
	if at:IsControler(tp) and at:IsCode(19712864) and def:IsFaceup() and def:IsAttribute(ATTRIBUTE_DARK) then
		return true
	end
	return false
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local def=Duel.GetAttackTarget()
	if def and def:IsRelateToBattle() then
		Duel.Destroy(def,REASON_EFFECT)
	end
end
