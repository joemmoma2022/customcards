local s,id=GetID()

local SET_GRIMOIRE = 0x611
local COUNTER_MANA = 0x8960

s.attack_effects = {}

function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	--Flip at duel start
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
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function()
		return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	end)
	e1:SetOperation(s.flipop)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local fid=c:GetFieldID()

	--Continuous ATK reduction each Standby Phase (permanent)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
	e1:SetOperation(s.standbyop)
	Duel.RegisterEffect(e1,tp)

	--Continuous restriction while face-up: cannot attack & cannot change position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TRUE)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TRUE)
	Duel.RegisterEffect(e3,tp)

	s.attack_effects[fid]={atk=e1,atklock=e2,poslock=e3}

	--Effect to flip-down via Grimoire Mana
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.flipdowncon)
	e4:SetOperation(s.flipdownop)
	Duel.RegisterEffect(e4,tp)
	s.attack_effects[fid].flipdown=e4
end

--Standby Phase operation: permanent ATK reduction
function s.standbyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) -- No phase reset → permanent
		tc:RegisterEffect(e1)
	end
end

--Grimoire filter for flip-down
function s.manafilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GRIMOIRE) and c:GetCounter(COUNTER_MANA)>=4
end

--Flip-down condition
function s.flipdowncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and Duel.IsExistingMatchingCard(s.manafilter,tp,LOCATION_ONFIELD,0,1,nil)
end

--Flip-down operation
function s.flipdownop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()

	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectMatchingCard(tp,s.manafilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	tc:RemoveCounter(tp,COUNTER_MANA,4,REASON_COST)

	--Remove all continuous effects
	if s.attack_effects[fid] then
		for _,eff in pairs(s.attack_effects[fid]) do
			if eff then eff:Reset() end
		end
		s.attack_effects[fid]=nil
	end

	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.ChangePosition(c,POS_FACEDOWN)
end
