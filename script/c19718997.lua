local s,id=GetID()

-- Counter ID for Inferno Counter
local INFERNO_COUNTER=0x1319

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Start of Duel: Add cards to hand/Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	-- Passive protections
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.proteffect1)
	e2:SetValue(s.indval)
	Duel.RegisterEffect(e2,0)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.proteffect2)
	e3:SetValue(1)
	Duel.RegisterEffect(e3,0)
end

-- Start of Duel: Add Inferno Crystal to Extra, Beetle to Hand, and search 1 Gem-Knight Normal
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Gem-Knight Inferno Crystal to Extra Deck
	local inferno=Duel.CreateToken(tp,19712840)
	Duel.SendtoDeck(inferno,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Gem-Mech God Beetle to hand
	local beetle=Duel.CreateToken(tp,19712855)
	Duel.SendtoHand(beetle,tp,REASON_RULE)

	-- Search 1 Gem-Knight Normal from Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,function(c)
		return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
	end,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_RULE)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Skill activation condition: Must control Inferno Crystal and be able to use at least part of the effect
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if not aux.CanActivateSkill(tp) then return false end
	local inferno=Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(19712840)
	end,tp,LOCATION_MZONE,0,1,nil)
	if not inferno then return false end

	-- Check if there's something to revive and a counter to remove
	local can_remove=Duel.IsExistingMatchingCard(function(c)
		return c:IsCanRemoveCounter(tp,INFERNO_COUNTER,1,REASON_EFFECT)
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local gy_target=Duel.IsExistingMatchingCard(function(c)
		return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,tp,LOCATION_GRAVE,0,1,nil)

	return true -- always true if Inferno Crystal is present, counter adding is guaranteed
end

-- Skill effect operation
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Select Inferno Crystal to add counter
	local g=Duel.GetMatchingGroup(s.infernofilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	tc:AddCounter(INFERNO_COUNTER,1)

	-- Optional revive
	local hasCounter=Duel.IsExistingMatchingCard(function(c)
		return c:IsCanRemoveCounter(tp,INFERNO_COUNTER,1,REASON_EFFECT)
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local gyTarget=Duel.IsExistingMatchingCard(function(c)
		return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,tp,LOCATION_GRAVE,0,1,nil)

	if hasCounter and gyTarget and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local ctc=Duel.SelectMatchingCard(tp,function(c)
			return c:IsCanRemoveCounter(tp,INFERNO_COUNTER,1,REASON_EFFECT)
		end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if ctc and ctc:RemoveCounter(tp,INFERNO_COUNTER,1,REASON_EFFECT) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local spc=Duel.SelectMatchingCard(tp,function(c)
				return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
			if spc then
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

-- Filter for selecting Inferno Crystal
function s.infernofilter(c)
	return c:IsFaceup() and c:IsCode(19712840)
end

-- Count total Inferno Counters on your field
function s.total_inferno_counters(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	local total=0
	for tc in g:Iter() do
		total = total + tc:GetCounter(INFERNO_COUNTER)
	end
	return total
end

-- Protection from effect destruction: only if player has Inferno Crystal + 3+ total Inferno Counters
function s.proteffect1(e,c)
	return c:IsFaceup() and c:IsCode(19712840)
		and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(19712840) end,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and s.total_inferno_counters(c:GetControler())>=3
end

-- Protection from battle destruction: applies to Gem-Knight Normals if player has Inferno Crystal + 3+ counters
function s.proteffect2(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL)
		and Duel.IsExistingMatchingCard(function(fc) return fc:IsFaceup() and fc:IsCode(19712840) end,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and s.total_inferno_counters(c:GetControler())>=3
end

-- Only protects from opponent’s effects
function s.indval(e,re,tp)
	return e:GetHandlerPlayer()~=tp
end
