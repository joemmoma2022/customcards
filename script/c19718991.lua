local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Start-of-Duel setup
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
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Create cards from outside the Duel
	local kagura=Duel.CreateToken(tp,19712860)      -- Armor Shinobi Kagura
	local oogama=Duel.CreateToken(tp,19712861)      -- Armor RoboToad Oogama
	local contspell=Duel.CreateToken(tp,19718992)   -- Your custom Continuous Spell

	-- Add Kagura to Extra Deck
	if kagura then
		local g1=Group.CreateGroup()
		g1:AddCard(kagura)
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Add Oogama to hand
	if oogama then
		Duel.SendtoHand(oogama,nil,REASON_RULE)
	end

	-- Place Continuous Spell to Spell/Trap Zone if there's space
	if contspell and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(contspell,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
