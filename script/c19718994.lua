local s,id=GetID()

-- Counter IDs
local RABBIT_COUNTER = 0x111f
local TANK_COUNTER = 0x1120

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup: Add 3 monsters to hand
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

	-- Passive effect: All "T.G." monsters become Beast and Machine
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
	e2:SetTarget(function(_,c) return c:IsSetCard(0x27) end)
	e2:SetValue(RACE_BEAST+RACE_MACHINE)
	Duel.RegisterEffect(e2,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local cards={
		Duel.CreateToken(tp,19712856), -- Red Rabbit
		Duel.CreateToken(tp,19712857), -- Blue Tank
		Duel.CreateToken(tp,19712858)  -- T.G. Striker RabbitTank
	}
	for _,c in ipairs(cards) do
		Duel.SendtoHand(c,tp,REASON_RULE)
	end
end

function s.rabbittankfilter(c)
	return c:IsFaceup() and c:IsCode(19712858)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local rabbittank=Duel.GetFirstMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,nil)
	if not rabbittank then return end

	Duel.Hint(HINT_CARD,tp,id)
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,1)}, -- Add counter
		{Duel.GetLP(1-tp)<=2000,aux.Stringid(id,2)}  -- Burn effect (only available if opponent has <= 2000 LP)
	)

	if op==1 then
		-- Choose counter type
		local ct=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		local counter_id=(ct==0) and RABBIT_COUNTER or TANK_COUNTER
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			tc:AddCounter(counter_id,1)
		end
	elseif op==2 then
		-- Burn effect: Remove all RABBIT and TANK counters on the field
		local g=Duel.GetMatchingGroup(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		local ct=0
		for tc in g:Iter() do
			ct=ct+tc:GetCounter(RABBIT_COUNTER)+tc:GetCounter(TANK_COUNTER)
			tc:RemoveCounter(tp,RABBIT_COUNTER,tc:GetCounter(RABBIT_COUNTER),REASON_EFFECT)
			tc:RemoveCounter(tp,TANK_COUNTER,tc:GetCounter(TANK_COUNTER),REASON_EFFECT)
		end
		if ct>0 then
			Duel.Damage(1-tp,Duel.GetLP(1-tp),REASON_EFFECT)
		end
	end
end
