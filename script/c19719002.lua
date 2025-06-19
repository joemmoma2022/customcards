local s,id=GetID()
local FIRE_MAG_ID=19712843
local INCANTATION_ID=19712875

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Add Arcanite Fire Magician and Incantation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

-- Startup: Add cards from outside the duel
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Arcanite Fire Magician to Extra Deck
	local firemag=Duel.CreateToken(tp,FIRE_MAG_ID)
	Duel.SendtoDeck(firemag,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Fire Magicians' Incantation to Hand
	local incant=Duel.CreateToken(tp,INCANTATION_ID)
	Duel.SendtoHand(incant,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,incant)
end

-- Skill Activation Condition: Once per turn, you control Arcanite Fire Magician
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,FIRE_MAG_ID),tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,FIRE_MAG_ID),tp,LOCATION_MZONE,0,1,1,nil)
	local c=g:GetFirst()
	if not c then return end

	local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))

	if opt==0 then
		c:AddCounter(COUNTER_SPELL,1)
	elseif opt==1 and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,1,REASON_COST) then
		if Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,1,REASON_COST) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
			local attr=Duel.AnnounceAttribute(tp,1,
				ATTRIBUTE_EARTH|ATTRIBUTE_FIRE|ATTRIBUTE_WATER|ATTRIBUTE_WIND)
			local tg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=tg:GetFirst()
			if tc then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e1:SetValue(attr)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end
