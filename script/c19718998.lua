-- Hi-Speedroid Warrior Tridoron Skill
-- Scripted by ChatGPT, based on The Razgriz template

local s,id=GetID()
local TRIDORON_ID=19712871
local SPEED_SPELL_ID=19712872
local RED_EYED_DICE_ID=16725505
local TURN_JUMP_ID=19712873

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: add cards at duel start
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	-- Passive: negate Super Speed and activate Turn Jump
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- Startup operation
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Tridoron
	local tridoron=Duel.CreateToken(tp,TRIDORON_ID)
	Duel.SendtoHand(tridoron,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,tridoron)

	-- Add Speedroid‑Type: SPEED!
	local speed_spell=Duel.CreateToken(tp,SPEED_SPELL_ID)
	Duel.SendtoHand(speed_spell,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,speed_spell)

	-- Add Red-Eyed Dice
	local dice=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,RED_EYED_DICE_ID)
	if dice then
		Duel.SendtoHand(dice,tp,REASON_RULE)
		Duel.ConfirmCards(1-tp,dice)
	end
end

-- Super Speed negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=re:GetHandler()
	return rc:IsSetCard(0x9d) and Duel.IsChainNegatable(ev) -- Replace 0x9d with actual Set if needed
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.NegateActivation(ev) then
		local tj=Duel.CreateToken(tp,TURN_JUMP_ID)
		Duel.MoveToField(tj,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

-- Send-to-GY filter
function s.tgfilter(c)
	return (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_DRAGON)) and c:IsAbleToGraveAsCost()
end

-- Once-per-turn Skill button condition
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,TRIDORON_ID),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end

-- Skill button effect: Send 1 Machine/Dragon from Deck to GY
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
