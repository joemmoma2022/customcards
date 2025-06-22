--Cookpal Support Card (Name TBD)
local s,id=GetID()
local CARD_FOOD_CEMETERY=19712959
local CARD_COOKPAL_RABBITOMATO=19712954

function s.initial_effect(c)
	-- Effect 1: If returned to hand by effect of "Cookpal" monster, place beneath a "Food Cemetery" you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.placecon)
	e1:SetTarget(s.placetg)
	e1:SetOperation(s.placeop)
	c:RegisterEffect(e1)
	
	-- Effect 2: If destroyed by battle, Special Summon 1 "Cookpal Rabbitomato" from deck and place this card beneath a "Food Cemetery" you control in GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={0x512} -- Cookpal
s.listed_names={CARD_FOOD_CEMETERY,CARD_COOKPAL_RABBITOMATO}

function s.placecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsSetCard(0x512) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end

function s.fcfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_FOOD_CEMETERY)
end

function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_ONFIELD,0,1,nil) end
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local fc=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if fc and c:IsRelateToEffect(e) then
		fc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		c:CancelToGrave()
		c:SetCardTarget(fc)
	end
end

function s.spfilter(c,e,tp)
	return c:IsCode(CARD_COOKPAL_RABBITOMATO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local fc=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
			if fc then
				c:SetCardTarget(fc)
			end
		end
	end
end
