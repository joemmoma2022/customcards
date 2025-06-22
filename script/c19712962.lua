--Trap: Food Cemetery Conjuration
local s,id=GetID()
local FOOD_CEMETERY_ID=19712959

function s.initial_effect(c)
	--Trigger: Place monsters under "Food Cemetery"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.placecon)
	e1:SetTarget(s.placetg)
	e1:SetOperation(s.placeop)
	c:RegisterEffect(e1)

	--Banish: Destroy monsters and place them under "Food Cemetery"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

-- Filter: Cards added to hand by opponent (not Draw Phase)
function s.addfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end

function s.placecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.addfilter,1,nil,tp)
end

function s.placecemfilter(c)
	return c:IsFaceup() and c:IsCode(FOOD_CEMETERY_ID)
end

function s.monfilter(c)
	return c:IsMonster() and not c:IsImmuneToEffect(e)
end

function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.addfilter,nil,tp)
	if chk==0 then 
		return ct>0 
			and Duel.IsExistingMatchingCard(s.placecemfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_GRAVE,0,ct,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,ct,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.addfilter,nil,tp)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local cem=Duel.SelectMatchingCard(tp,s.placecemfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not cem then return end

	local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_GRAVE,0,ct,ct,nil)
	for tc in aux.Next(g) do
		tc:CancelToGrave()
		tc:SetCardTarget(cem)
	end
end

-- GY effect: Destroy and attach targets
function s.get_attached_count(cem)
	local ct=0
	local g=Duel.GetMatchingGroup(Card.IsHasCardTarget,cem:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK+LOCATION_HAND,0,nil)
	for tc in aux.Next(g) do
		if tc:IsHasCardTarget(cem) then
			ct=ct+1
		end
	end
	return ct
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cem=Duel.GetFirstMatchingCard(s.placecemfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return cem and s.get_attached_count(cem)>0 
			and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,s.get_attached_count(cem),1-tp,LOCATION_MZONE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local cem=Duel.GetFirstMatchingCard(s.placecemfilter,tp,LOCATION_ONFIELD,0,nil)
	if not cem then return end
	local ct=s.get_attached_count(cem)
	if ct==0 then return end
	local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,ct,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		for tc in aux.Next(g) do
			tc:CancelToGrave()
			tc:SetCardTarget(cem)
		end
	end
end
