--Royal Cookpal Feast (Spell Card)
local s,id=GetID()
local SET_ROYAL_COOKPAL=0x1512
local CARD_FOOD_CEMETERY=19712959

function s.initial_effect(c)
	--Activate: Special Summon from hand or GY up to the number of cards under Food Cemetery, then burn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_ROYAL_COOKPAL}
s.listed_names={CARD_FOOD_CEMETERY}

-- Count how many cards are targeted by any face-up "Food Cemetery" you control
function s.cemetery_count(tp)
	local g=Duel.GetMatchingGroup(s.fcfilter,tp,LOCATION_ONFIELD,0,nil)
	local total=0
	for tc in aux.Next(g) do
		total=total+#tc:GetCardTarget()
	end
	return total
end

function s.fcfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_FOOD_CEMETERY)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ROYAL_COOKPAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local max=s.cemetery_count(tp)
	if chk==0 then return max>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local max=s.cemetery_count(tp)
	if max<=0 then return end
	if max>ft then max=ft end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,max,nil)
	if #sg>0 then
		local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		if ct>0 then
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
