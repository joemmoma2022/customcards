--Mantis Egg (Field Spell)
local s,id=GetID()
local TOKEN_BABY_MANTIS=19712975

function s.initial_effect(c)
	-- Activate only if you control a "Mantis" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)

	-- Special Summon Baby Mantis Tokens during Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Mantis monsters gain 500 ATK per Baby Mantis Token on the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
s.listed_series={0x535}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x535),tp,LOCATION_MZONE,0,1,nil)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct = Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local ft = Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft < ct then ct = ft end
	if chk==0 then
		return ct > 0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0x535,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft = Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct = Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if ft < ct then ct = ft end
	if ct <= 0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0x535,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then return end

	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_BABY_MANTIS)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			-- Auto-destroy at end phase (forced)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabelObject(token)
			e1:SetCondition(s.descon)
			e1:SetOperation(s.desop)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
			Duel.RegisterEffect(e1,tp)
		end
	end
	Duel.SpecialSummonComplete()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField()
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x535)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.tokenfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end

function s.tokenfilter(c)
	return c:IsFaceup() and c:IsCode(TOKEN_BABY_MANTIS)
end
