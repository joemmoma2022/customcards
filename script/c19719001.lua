local s,id=GetID()

-- Card IDs
local METEOR_KNIGHT=19712869
local METEORSTRIKE=19712870
local PHOTON_DRAGON=93717133

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Add cards to Extra Deck and Hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)

	-- Trigger: LP would become 0 → set to 1 instead (once per Duel)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(s.lpcheckcon)
	e2:SetOperation(s.lpcheckop)
	Duel.RegisterEffect(e2,0)
end

-- Startup Operation
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	Duel.Hint(HINT_SKILL_FLIP,p,id|(1<<32))
	Duel.Hint(HINT_CARD,p,id)

	-- Add Galaxy-Eyes Meteor Knight to Extra Deck
	local meteor_knight_token=Duel.CreateToken(p,METEOR_KNIGHT)
	Duel.SendtoDeck(meteor_knight_token,p,SEQ_DECKTOP,REASON_RULE)

	-- Add Galaxy-Eyes Meteorstrike to hand
	local meteorstrike_token=Duel.CreateToken(p,METEORSTRIKE)
	Duel.SendtoHand(meteorstrike_token,p,REASON_RULE)
	Duel.ConfirmCards(1-p,meteorstrike_token)

	-- Add Galaxy-Eyes Photon Dragon from Deck to hand
	local photon=Duel.GetFirstMatchingCard(Card.IsCode,p,LOCATION_DECK,0,nil,PHOTON_DRAGON)
	if photon then
		Duel.SendtoHand(photon,p,REASON_RULE)
		Duel.ConfirmCards(1-p,photon)
	end
end

-- Trigger Condition: Your LP would be reduced to 0
function s.lpcheckcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetLP(tp)<=ev and Duel.GetFlagEffect(tp,id)==0
end

-- Trigger Operation: Set LP to 1 instead
function s.lpcheckop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SetLP(tp,1)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- Flip Condition: You control Galaxy-Eyes Meteor Knight
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,METEOR_KNIGHT)
end

-- Flip Operation: Galaxy-Eyes Meteor Knight can attack again if it banishes
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Apply extra attack if Meteor Knight banishes a monster
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsCode(METEOR_KNIGHT) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
