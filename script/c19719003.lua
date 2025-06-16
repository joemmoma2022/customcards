-- Digital Distortion
-- Scripted by You
local s,id=GetID()

-- Counter ID
local ROCKIN_COUNTER = 0x1320

function s.initial_effect(c)
	-- Flip skill: Once per duel
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup operation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

-- Startup: Bloom to Extra Deck, Rockin' to hand, apply field modifiers
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Bloom Vocaloid to Extra Deck
	local bloom=Duel.CreateToken(tp,19712877)
	Duel.SendtoDeck(bloom,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Digital Rockin’ to hand and reveal
	local rockin=Duel.CreateToken(tp,19712876)
	Duel.SendtoHand(rockin,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,rockin)

	-- ATK boost for all monsters based on your Rockin’ Counters
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.statfilter)
	e2:SetValue(s.atkval)
	Duel.RegisterEffect(e2,tp)

	-- DEF drop for all monsters based on your Rockin’ Counters
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(s.defval)
	Duel.RegisterEffect(e3,tp)
end

-- Flip skill condition: Bloom must be face-up
function s.bloomfilter(c)
	return c:IsFaceup() and c:IsCode(19712877)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(s.bloomfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Flip skill: Give 1 Rockin’ Counter to 1 face-up Melodious you control
function s.melodiousfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
		and c:IsCanAddCounter(ROCKIN_COUNTER,1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.melodiousfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		tc:AddCounter(ROCKIN_COUNTER,1)
	end
end

-- Affects all face-up monsters
function s.statfilter(e,c)
	return c:IsFaceup()
end

-- Total Rockin’ Counters YOU control
local function total_rockin(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local count=0
	for tc in aux.Next(g) do
		count = count + tc:GetCounter(ROCKIN_COUNTER)
	end
	return count
end

function s.atkval(e,c)
	return total_rockin(e:GetHandlerPlayer()) * 500
end

function s.defval(e,c)
	return -total_rockin(e:GetHandlerPlayer()) * 400
end
