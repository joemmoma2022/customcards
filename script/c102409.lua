-- Grimoire Dice Hex
-- Skill
local s,id=GetID()

local SET_GRIMOIRE = 0x611
local COUNTER_MANA = 0x8960

-- Table to store attack effects safely
s.attack_effects = {}

function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Startup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

-- ========== STARTUP / FLIP ==========
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function()
		return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	end)
	e1:SetOperation(s.flipop)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local fid=c:GetFieldID()

	-- Attack declaration check (dice effect)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.faceupcon)
	e1:SetOperation(s.atkop)
	Duel.RegisterEffect(e1,tp)

	-- Store effect reference safely
	s.attack_effects[fid] = e1

	-- Manual flip-down (remove 3 Mana = DISABLE SKILL)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.flipdowncon)
	e2:SetOperation(s.flipdownop)
	Duel.RegisterEffect(e2,tp)
end

-- ========== FACE-UP / ATTACK CHECK ==========
function s.faceupcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.GetAttacker()~=nil
		and Duel.GetAttacker():IsControler(tp)
end

-- ========== ATTACK DIE EFFECT ==========
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local call=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
	local roll=Duel.TossDice(tp,1)

	if roll~=call then
		Duel.NegateAttack()
	end
end

-- ========== FLIP-DOWN COST ==========
function s.flipdowncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
		and Duel.IsExistingMatchingCard(s.manafilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.manafilter(c)
	return c:IsFaceup()
		and c:IsSetCard(SET_GRIMOIRE)
		and c:GetCounter(COUNTER_MANA)>=3
end

function s.flipdownop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()

	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.manafilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	-- Remove 3 Mana Points (COST)
	tc:RemoveCounter(tp,COUNTER_MANA,3,REASON_COST)

	-- HARD DISABLE the attack effect
	if s.attack_effects[fid] then
		s.attack_effects[fid]:Reset()
		s.attack_effects[fid] = nil
	end

	-- Visual flip-down
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.ChangePosition(c,POS_FACEDOWN)
end
