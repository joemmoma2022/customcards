--Cookpal Support Card (Name TBD)
local s,id=GetID()
local CARD_FOOD_CEMETERY=19712959
local SET_ROYAL_COOKPAL=0x1512
local SET_COOKPAL=0x512

function s.initial_effect(c)
	--Effect 1: Activate to add 2 "Royal Cookpal" monsters from Deck to hand and restrict summoning this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--Effect 2: Banish from GY to attach 1 "Cookpal" monster from GY under a "Food Cemetery" you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(0)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_COOKPAL,SET_ROYAL_COOKPAL}
s.listed_names={CARD_FOOD_CEMETERY}

-- Effect 1: Filters for "Royal Cookpal" monsters in Deck that can be added to hand
function s.thfilter(c)
	return c:IsSetCard(SET_ROYAL_COOKPAL) and c:IsMonster() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		-- Apply summon restriction on these cards this turn
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end

-- Effect 2: Filter for face-up "Food Cemetery"
function s.fcfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_FOOD_CEMETERY)
end

-- Effect 2: Filter for "Cookpal" monsters in GY that can be attached
function s.cfilter(c)
	return c:IsSetCard(SET_COOKPAL) and c:IsMonster() and c:IsAbleToChangeControler()
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local fc=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not fc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not tc then return end
	if fc:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- Attach the selected "Cookpal" monster to the Food Cemetery as material (beneath)
		tc:CancelToGrave()
		tc:SetCardTarget(fc)
	end
end
