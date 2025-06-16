-- Dissonant Note Call
-- Scripted by You
local s,id=GetID()

function s.initial_effect(c)
	-- Activate if you control a Melodious monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Condition: You control a Melodious monster
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Target: Can we summon 3 tokens?
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>2 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,19712878,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end

-- Activate: Create 3 restricted tokens and lock Extra Deck
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,19712878,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end

	for i=1,3 do
		local token=Duel.CreateToken(tp,19712878)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)

		-- Token cannot be tributed, except for Melodious Maestra
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(s.rellimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2)

		-- Cannot be used as material except for Melodious
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetValue(s.matlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e3)
	end
	Duel.SpecialSummonComplete()

	-- Restrict Extra Deck summons this turn (non-Melodious)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.extralimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
end

-- Tribute Limit: Only for Melodious Maestra
function s.rellimit(e,c)
	return not (c:IsSetCard(0x9b) and c:IsLevelAbove(6))
end

-- Material Limit: Only for Melodious
function s.matlimit(e,c)
	return not c:IsSetCard(0x9b)
end

-- Extra Deck Restriction: Only Melodious this turn
function s.extralimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x9b)
end
