-- T.G. Evolution Drive (Skill Card)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Auto-flip at start and add key cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

-- Start of Duel effect: flip and add cards
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Create and add Red Rabbit and Blue Tank to hand
	local red=Duel.CreateToken(tp,19712856)
	local blue=Duel.CreateToken(tp,19712857)
	if red then Duel.SendtoHand(red,nil,REASON_RULE) end
	if blue then Duel.SendtoHand(blue,nil,REASON_RULE) end

	-- Create and add Striker RabbitTank to Extra Deck
	local xyz=Duel.CreateToken(tp,19712858)
	if xyz then
		local g=Group.CreateGroup()
		g:AddCard(xyz)
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Setup passive type effects and ignition counter effect
	s.setup_continuous_effects(e,tp)
end

-- Setup effects while controlling RabbitTank
function s.setup_continuous_effects(e,tp)
	-- Continuous passive effect: race changes
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.race_type_effect)
	e1:SetCondition(function() return Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil) end)
	Duel.RegisterEffect(e1,tp)

	-- Ignition effect: Add counter to Striker RabbitTank
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_MAIN1)
	e2:SetRange(LOCATION_ALL)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetOperation(s.counter_ignition_op)
	Duel.RegisterEffect(e2,tp)

	-- Kill effect: if opponent has 2000 or less LP and both counters are present
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetCondition(function(_,tp) return Duel.GetLP(1-tp)<=2000 and s.has_counters(tp) end)
	e3:SetOperation(s.lp_finish_op)
	Duel.RegisterEffect(e3,tp)
end

-- Filter for T.G. Striker RabbitTank
function s.rabbittankfilter(c)
	return c:IsFaceup() and c:IsCode(19712858)
end

-- Filter for T.G. monsters
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end

-- Add Beast + Machine race to all T.G. monsters you control
function s.race_type_effect(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		if not tc:IsRace(RACE_BEAST) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_RACE)
			e1:SetValue(RACE_BEAST)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if not tc:IsRace(RACE_MACHINE) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_RACE)
			e2:SetValue(RACE_MACHINE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

-- Once per turn ignition: place counter on your RabbitTank
function s.counter_ignition_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.rabbittankfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- "Rabbit"/"Tank"
	if opt==0 then
		tc:AddCounter(0x111f,1)
	else
		tc:AddCounter(0x1120,1)
	end
end

-- Check if any cards have at least 1 of each counter
function s.has_counters(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return g:GetSum(Card.GetCounter,0x111f)>0 and g:GetSum(Card.GetCounter,0x1120)>0
end

-- If opponent LP ≤ 2000 and both counter types exist: burn for exact LP
function s.lp_finish_op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_CARD,tp,id)

	-- Remove all counters
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in g:Iter() do
		tc:RemoveCounter(tp,0x111f,tc:GetCounter(0x111f),REASON_EFFECT)
		tc:RemoveCounter(tp,0x1120,tc:GetCounter(0x1120),REASON_EFFECT)
	end

	local lp=Duel.GetLP(1-tp)
	Duel.Damage(1-tp,lp,REASON_EFFECT)
end
