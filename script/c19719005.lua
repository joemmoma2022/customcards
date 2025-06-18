-- Ancient Gear Reinforcement
-- Scripted by You
local s,id=GetID()

local GREASED_GOLEM_ID=19712882
local TWIN_BREAKER_ID=19712883 -- Replace with actual ID
local ANCIENT_GEAR_CARD_ID=31557782 -- Card "Ancient Gear" specifically

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,2)

	-- Startup effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local greased=Duel.CreateToken(tp,GREASED_GOLEM_ID)
	Duel.SendtoDeck(greased,tp,SEQ_DECKSHUFFLE,REASON_RULE)

	local twin=Duel.CreateToken(tp,TWIN_BREAKER_ID)
	Duel.SendtoHand(twin,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,twin)

	local g=Duel.GetMatchingGroup(function(c)
		return c:IsCode(ANCIENT_GEAR_CARD_ID) and c:IsAbleToGrave()
	end,tp,LOCATION_DECK,0,nil)
	if #g>=2 then
		local sg=g:Select(tp,2,2,nil)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetTurnPlayer()==tp
		and Duel.GetFlagEffect(tp,id)<2 -- Max twice per Duel
		and Duel.GetFlagEffect(tp,id+1)==0 -- Not already used this turn
		and Duel.IsExistingMatchingCard(s.condfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.condfilter(c)
	local eg=c:GetEquipGroup()
	return c:IsFaceup() and c:IsCode(GREASED_GOLEM_ID)
		and eg and eg:IsExists(Card.IsCode,1,nil,TWIN_BREAKER_ID)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Lock for this turn
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	-- Count total use
	Duel.RegisterFlagEffect(tp,id,0,0,1)

	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #sg>0 then
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

function s.tdfilter(c)
	return c:IsCode(ANCIENT_GEAR_CARD_ID) and c:IsAbleToDeck()
end

function s.setfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
