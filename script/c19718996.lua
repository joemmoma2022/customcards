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

	-- Add Condemned Darklord - Hyperion to Extra Deck
	local hyperion=Duel.CreateToken(tp,19712865)
	Duel.SendtoDeck(hyperion,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Possessed Darklord - Morningstar to hand
	local morningstar=Duel.CreateToken(tp,19712866)
	Duel.SendtoHand(morningstar,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,morningstar)

	-- Place Desecrated Sanctuary face-up in Field Zone
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,nil,19712868)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end

	-- Register passive effects globally AFTER field spell is placed
	if tp~=nil then
		-- Destroy LIGHT monsters you summon or control
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(s.lightdescon)
		e1:SetOperation(s.lightdesop)
		Duel.RegisterEffect(e1,tp)

		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e2,tp)

		-- Once per turn, Desecrated Sanctuary cannot be destroyed
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetTargetRange(LOCATION_FZONE,0)
		e3:SetCondition(s.sanctuarycon)
		e3:SetValue(s.indestructableval)
		Duel.RegisterEffect(e3,tp)

		local e_reset=Effect.CreateEffect(e:GetHandler())
		e_reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e_reset:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e_reset:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e_reset:SetOperation(s.resetflag)
		Duel.RegisterEffect(e_reset,tp)

		-- Destroy LIGHT monster attacked by Condemned Hyperion
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e4:SetCode(EVENT_ATTACK_ANNOUNCE)
		e4:SetCondition(s.lightattackcon)
		e4:SetOperation(s.lightattackop)
		Duel.RegisterEffect(e4,tp)

		-- Once per turn: attach 1 Darklord from GY to Condemned Hyperion
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_FREE_CHAIN)
		e5:SetOperation(s.attachop)
		e5:SetCondition(s.attachcon)
		Duel.RegisterEffect(e5,tp)

		-- If opponent controls Redeemed Agent Hyperion and you control Condemned Hyperion: nuke field and burn
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e6:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e6:SetCondition(s.nukecon)
		e6:SetOperation(s.nukeop)
		Duel.RegisterEffect(e6,tp)
	end
end

function s.controlcheck(tp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19712865)
	   and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_FZONE,0,1,nil,19712868)
end

-- LIGHT Monster Summon/Control Destruction
function s.lightdescon(e,tp,eg,ep,ev,re,r,rp)
	if not s.controlcheck(tp) then return false end
	return eg:IsExists(function(c) return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) end,1,nil)
end

function s.lightdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c) return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) end,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

-- Desecrated Sanctuary Indestructible Once Per Turn
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

-- Destroy LIGHT monster attacked by Condemned Hyperion
function s.lightattackcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	if not def or not at then return false end
	if at:IsControler(tp) and at:IsCode(19712865) and def:IsFaceup() and def:IsAttribute(ATTRIBUTE_LIGHT) then
		return true
	end
	return false
end

function s.lightattackop(e,tp,eg,ep,ev,re,r,rp)
	local def=Duel.GetAttackTarget()
	if def and def:IsRelateToBattle() then
		Duel.Destroy(def,REASON_EFFECT)
	end
end

-- Attach from GY
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 then return false end
	return s.controlcheck(tp)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER)
		end, tp, LOCATION_GRAVE, 0, 1, nil)
		and Duel.IsExistingMatchingCard(function(c)
			return c:IsFaceup() and c:IsCode(19712865) and c:IsType(TYPE_XYZ)
		end, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	local xyz=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:IsCode(19712865) and c:IsType(TYPE_XYZ)
	end,tp,LOCATION_MZONE,0,nil):GetFirst()

	local gy=Duel.GetMatchingGroup(function(c)
		return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER)
	end,tp,LOCATION_GRAVE,0,nil)

	if not xyz or #gy==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mat=gy:Select(tp,1,1,nil):GetFirst()
	if mat and xyz then
		Duel.Overlay(xyz,Group.FromCards(mat))
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	end
end

-- Nuke condition
function s.nukecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19712865)
	   and Duel.IsExistingMatchingCard(Card.IsCode,1-tp,LOCATION_MZONE,0,1,nil,19712864)
end

function s.nukeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		local lp=Duel.GetLP(tp)
		Duel.Damage(tp,lp-1,REASON_EFFECT)
		Duel.Damage(1-tp,Duel.GetLP(1-tp)-1,REASON_EFFECT)
	end
end
