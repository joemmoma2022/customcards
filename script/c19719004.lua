-- Malevolent Evolution
-- Scripted by You
local s,id=GetID()

local C70_ID=19712842
local CAPTURE_ID=19712880
local NUM70_ID=80796456

-- Skill Activation
function s.initial_effect(c)
	-- Flip skill: Once per duel
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Add Saligia to Extra Deck & Capture to hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

-- Startup operation
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Saligia to Extra Deck
	local saligia=Duel.CreateToken(tp,C70_ID)
	Duel.SendtoDeck(saligia,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Capture to hand and reveal
	local capture=Duel.CreateToken(tp,CAPTURE_ID)
	Duel.SendtoHand(capture,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,capture)
end

-- Flip condition: Control Number 70 or Number C70
function s.malevolentfilter(c)
	return c:IsFaceup() and (c:IsCode(NUM70_ID) or c:IsCode(C70_ID))
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(s.malevolentfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Create attack boost effect that triggers on your Malevolent monster's attack
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	e1:SetCountLimit(1,id) -- Once per Duel
	Duel.RegisterEffect(e1,tp)
end

-- Condition: Your Malevolent monster attacks
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc:IsControler(tp) and tc:IsFaceup()
		and (tc:IsCode(NUM70_ID) or tc:IsCode(C70_ID))
end

-- Operation: Reduce LP to 1, boost ATK by lost LP during damage calculation
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or Duel.GetLP(tp)<=1 then return end

	local lost_lp = Duel.GetLP(tp) - 1
	Duel.SetLP(tp,1)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_CAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(lost_lp)
	tc:RegisterEffect(e1)

	Duel.Hint(HINT_CARD,tp,id)
end
