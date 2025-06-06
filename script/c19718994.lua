--Believe in your Bro
--Scripted by The Razgriz, modified with fixes
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	-- Do NOT set range here; it's invalid for skill effects
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- Counter IDs
local RABBIT_COUNTER = 0x111f
local TANK_COUNTER = 0x1120

-- Startup: Add 3 monsters to hand
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

-- Only allow skill to flip if RabbitTank is on field
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local rabbittank=Duel.GetMatchingGroup(s.rabbittankfilter,tp,LOCATION_MZONE,0,nil):GetFirst()
	if not rabbittank then return end
	Duel.Hint(HINT_CARD,tp,id)

	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,1)}, -- Add counter
		{Duel.GetLP(1-tp)<=2000,aux.Stringid(id,2)}  -- Burn effect (if opponent has 2000 or less LP)
	)

	if op==1 then
		-- Choose counter type
		local ct=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		local counter_id=(ct==0) and RABBIT_COUNTER or TANK_COUNTER
		rabbittank:AddCounter(counter_id,1)
	elseif op==2 then
		-- Count and remove all Rabbit and Tank counters on the field
		local ct=Duel.GetCounter(tp,1,1,RABBIT_COUNTER)+Duel.GetCounter(tp,1,1,TANK_COUNTER)
		if ct>0 then
			Duel.RemoveCounter(tp,1,1,RABBIT_COUNTER,ct,REASON_EFFECT)
			Duel.RemoveCounter(tp,1,1,TANK_COUNTER,ct,REASON_EFFECT)
			Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
		end
	end
end

function s.rabbittankfilter(c)
	return c:IsFaceup() and c:IsCode(19712858)
end
