--Cookpal Surprise Pie
local s,id=GetID()
local TOKEN_ID=19712963
function s.initial_effect(c)
	--Activate: When opponent's monster(s) leave the field while you control a Cookpal/Royal Cookpal
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x512,0x1512}

function s.filter(c,tp)
	return not c:IsPreviousControler(tp) and c:IsMonster()
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x512) or c:IsSetCard(0x1512))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter,nil,tp)
	return ct>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.filter,nil,tp)
	if chk==0 then 
		return ct>0 
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=ct
			and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ID,0,TYPES_TOKEN,1000,1000,3,RACE_SPELLCASTER,ATTRIBUTE_DARK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter,nil,tp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<ct then return end
	if not (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ID,0,TYPES_TOKEN,1000,1000,3,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end

	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_ID)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
