local s,id=GetID()

local SET_GRIMOIRE = 0x611
local COUNTER_MANA = 0x8960

function s.initial_effect(c)
	--Skill procedure
	aux.AddSkillProcedure(c,2,false,nil,nil)

	--Flip at start of duel
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
	--Flip skill at duel start
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function() return Duel.GetTurnCount()==1 and Duel.GetCurrentChain()==0 end)
	e1:SetOperation(s.flipup)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end

function s.flipup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--Continuous effect: during your Standby Phase, reduce ATK and lock monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
	e1:SetOperation(s.standbyop)
	Duel.RegisterEffect(e1,tp)
	c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY,0,1)
	s.cont_effect=e1

	--Effect to allow flip-down via mana
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.flipdowncon)
	e2:SetOperation(s.flipdownop)
	Duel.RegisterEffect(e2,tp)
	s.flip_effect=e2
end

--Standby Phase ATK reduction and lock
function s.standbyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		--Reduce ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
		tc:RegisterEffect(e1)
		--Cannot attack
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
		tc:RegisterEffect(e2)
		--Cannot change battle position
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
		tc:RegisterEffect(e3)
	end
end

--Filter for Grimoire cards with enough Mana
function s.manafilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GRIMOIRE) and c:GetCounter(COUNTER_MANA)>=4
end

--Condition for flip-down
function s.flipdowncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.manafilter,tp,LOCATION_ONFIELD,0,1,nil)
end

--Flip-down operation
function s.flipdownop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.manafilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	tc:RemoveCounter(tp,COUNTER_MANA,4,REASON_COST)

	--Remove standby effects
	if s.cont_effect then
		s.cont_effect:Reset()
		s.cont_effect=nil
	end
	if s.flip_effect then
		s.flip_effect:Reset()
		s.flip_effect=nil
	end

	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.ChangePosition(c,POS_FACEDOWN)
end