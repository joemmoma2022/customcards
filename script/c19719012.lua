local s,id=GetID()
local HERO_IDS={19712009, 19712894, 19712895, 19712896, 19712938, 19712940, 19712941, 19712942, 19712943, 19712944}

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Flip this skill card and add the Masked HERO cards to the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Flip the skill card
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add all listed Masked HERO cards to Extra Deck
	for _,code in ipairs(HERO_IDS) do
		local token=Duel.CreateToken(tp,code)
		Duel.SendtoDeck(token,tp,SEQ_DECKTOP,REASON_RULE)
	end
end

-- Skill Activation Condition: Once per turn during your turn
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
end

-- Skill Effect: Declare 1 Attribute, a monster you control becomes that Attribute until end of turn
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)

	-- Select 1 monster you control to change attribute
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
