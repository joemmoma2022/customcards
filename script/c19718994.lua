-- T.G. Synchro Revolution
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Start of Duel
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)

	-- Beast + Machine typing for all "T.G." monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x27) end)
	e2:SetValue(RACE_BEAST+RACE_MACHINE)
	c:RegisterEffect(e2)

	-- Once per turn: Add a counter to "T.G. Striker RabbitTank"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.countercond)
	e3:SetTarget(s.countertg)
	e3:SetOperation(s.counterop)
	c:RegisterEffect(e3)

	-- LP Finish effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.finishcond)
	e4:SetOperation(s.finishop)
	c:RegisterEffect(e4)
end

-- Flip and add cards from outside the Duel
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Create the 3 cards
	local red=Duel.CreateToken(tp,19712856)
	local blue=Duel.CreateToken(tp,19712857)
	local rabbittank=Duel.CreateToken(tp,19712858)

	-- Add Red and Blue to hand
	Duel.SendtoHand(Group.FromCards(red,blue),nil,REASON_RULE)

	-- Add RabbitTank to Extra Deck
	local g=Group.CreateGroup()
	g:AddCard(rabbittank)
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_RULE)
end

-- Condition: You control a face-up "T.G. Striker RabbitTank"
function s.rabbittankfilter(c)
	return c:IsFaceup() and c:IsCode(19712858)
end
function s.countercond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Target 1 RabbitTank to add a counter
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rabbittankfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.rabbittankfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

-- Operation: Add a Rabbit or Tank counter
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local opt=Duel.SelectOption(tp,"Add Rabbit Counter","Add Tank Counter")
	if opt==0 then
		tc:AddCounter(0x111f,1) -- Rabbit
	else
		tc:AddCounter(0x1120,1) -- Tank
	end
end

-- Condition: Opponent LP ≤ 2000 and min 1 Rabbit and 1 Tank counter on the field
function s.finishcond(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(1-tp) > 2000 then return false end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	return g:FilterCount(function(c) return c:GetCounter(0x111f)>0 end,nil)>0
	   and g:FilterCount(function(c) return c:GetCounter(0x1120)>0 end,nil)>0
end

-- Remove all counters and deal damage equal to opponent's LP
function s.finishop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	for tc in aux.Next(g) do
		tc:RemoveCounter(tp,0x111f,tc:GetCounter(0x111f),REASON_EFFECT)
		tc:RemoveCounter(tp,0x1120,tc:GetCounter(0x1120),REASON_EFFECT)
	end
	local dmg=Duel.GetLP(1-tp)
	Duel.Damage(1-tp,dmg,REASON_EFFECT)
end
