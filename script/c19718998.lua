local s,id=GetID()
local TRIDORON_ID=19712871
local SPEED_SPELL_ID=19712872
local RED_EYED_DICE_ID=16725505
local SUPER_SPEED_NEGATION_SKILL_ID=19718999

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Add cards and place negation skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- Startup operation
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Tridoron to hand
	local tridoron=Duel.CreateToken(tp,TRIDORON_ID)
	Duel.SendtoHand(tridoron,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,tridoron)

	-- Add Speedroid-Type: SPEED! to hand
	local speed_spell=Duel.CreateToken(tp,SPEED_SPELL_ID)
	Duel.SendtoHand(speed_spell,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,speed_spell)

	-- Add Red-Eyed Dice from Deck to hand
	local dice=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,RED_EYED_DICE_ID)
	if dice then
		Duel.SendtoHand(dice,tp,REASON_RULE)
		Duel.ConfirmCards(1-tp,dice)
	end

	-- Place the Super Speed Negation Skill face-up in the Skill Zone
	local negation_skill=Duel.CreateToken(tp,SUPER_SPEED_NEGATION_SKILL_ID)
	Duel.MoveToField(negation_skill,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

-- Filter for Machine or Dragon-type monsters in Deck
function s.tgfilter(c)
	return (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_DRAGON)) and c:IsAbleToGraveAsCost()
end

-- Skill activation condition (Once per turn)
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,TRIDORON_ID),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
end

-- Send a Machine or Dragon-type from Deck to GY
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
