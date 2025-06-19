local s,id=GetID()

local CROSS_COUNTER=0x8083
local CROSS_Z_ID=19712841
local FLAME_STRIKE_ID=19712884

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	--Startup effect
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startup)
	c:RegisterEffect(e1)

	--ATK boost for Cross Z with 3+ counters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsCode(CROSS_Z_ID) and c:GetCounter(CROSS_COUNTER)>=3 end)
	e2:SetValue(function(e,c) return c:GetCounter(CROSS_COUNTER)*250 end)
	c:RegisterEffect(e2)
end

function s.startup(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--Add Odd-Eyes Cross Z Dragon to Extra Deck
	local token1=Duel.CreateToken(tp,CROSS_Z_ID)
	Duel.SendtoDeck(token1,tp,SEQ_DECKTOP,REASON_RULE)

	--Add Blue Flame Spiral Strike to Hand
	local token2=Duel.CreateToken(tp,FLAME_STRIKE_ID)
	Duel.SendtoHand(token2,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,token2)
end

-- This skill does not manually flip mid-duel
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return false
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
end
