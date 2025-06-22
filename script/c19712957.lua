--Cookpal Special Summon Spell (Name TBD)
local s,id=GetID()
local SET_ROYAL_COOKPAL=0x1512
local SET_COOKPAL=0x512
local CARD_FOOD_CEMETERY=19712959

function s.initial_effect(c)
	-- Activate: Special Summon "Royal Cookpal" monsters from hand whose level ≤ total opponent monster levels, return them at End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Banish from GY to attach opponent monsters beneath a Food Cemetery
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_ROYAL_COOKPAL,SET_COOKPAL}
s.listed_names={CARD_FOOD_CEMETERY}

-- Helper: get total opponent monster levels
function s.opp_level_sum(tp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local sum=0
	for tc in aux.Next(g) do
		sum=sum+tc:GetLevel()
	end
	return sum
end

-- Filter for Royal Cookpal monsters in hand with level ≤ lv
function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(SET_ROYAL_COOKPAL) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lvl=s.opp_level_sum(tp)
	if chk==0 then 
		if lvl<=0 then return false end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,lvl,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lvl=s.opp_level_sum(tp)
	if lvl<=0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,lvl,e,tp)
	if #g==0 then return end
	local sg=Group.CreateGroup()
	while ft>0 and #g>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		sg:AddCard(tc)
		g:RemoveCard(tc)
		ft=ft-1
	end
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		for tc in aux.Next(sg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetOperation(s.rettohand)
			tc:RegisterEffect(e1)
		end
	end
end

function s.rettohand(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- Filters opponent monsters for attachment
function s.opfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.fcfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_FOOD_CEMETERY)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_ROYAL_COOKPAL)
	if chk==0 then
		return ct>0 and Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(s.opfilter,tp,0,LOCATION_MZONE,ct,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,ct,0,0)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_ROYAL_COOKPAL)
	if ct<=0 then return end
	local fc=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not fc then return end
	local g=Duel.SelectMatchingCard(tp,s.opfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
	if #g==0 then return end
	for tc in aux.Next(g) do
		if tc:IsRelateToEffect(e) and fc:IsFaceup() then
			tc:CancelToGrave()
			tc:SetCardTarget(fc)
		end
	end
end
