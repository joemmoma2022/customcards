local s,id=GetID()
local COUNTER_THREAD=0x8370

function s.initial_effect(c)
	-- Enable Thread Counters
	c:EnableCounterPermit(COUNTER_THREAD)

	-- Activate: place 1 Thread Counter on all opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Monsters with Thread Counter cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	c:RegisterEffect(e2)

	-- Monsters with Thread Counter cannot change battle position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)

	-- Opponent's End Phase: burn 700 for each Thread Counter on field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.damcon)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)

	-- When this card leaves field: remove all Thread Counters
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(s.remop)
	c:RegisterEffect(e5)

	-- If it leaves the field, banish it instead
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e6)
end

-- Activation: place counters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		tc:AddCounter(COUNTER_THREAD,1)
	end
end

-- Restriction target (monster has Thread Counter)
function s.atktg(e,c)
	return c:GetCounter(COUNTER_THREAD)>0
end

-- Opponent's End Phase condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

-- Damage operation
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local total=Duel.GetCounter(0,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_THREAD)
	if total>0 then
		Duel.Damage(1-tp,total*700,REASON_EFFECT)
	end
end

-- Remove all Thread Counters when this leaves
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_THREAD,0xFFFF,REASON_EFFECT)
end
