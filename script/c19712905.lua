local s,id=GetID()
function s.initial_effect(c)
	-- Discard this card to search "Umi" or "Big Umi"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.searchcost)
	e1:SetTarget(s.searchtg)
	e1:SetOperation(s.searchop)
	c:RegisterEffect(e1)

	-- If you control Umi or Big Umi, once per turn: Discard 1 card, draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.drawcon)
	e2:SetCost(s.drawcost)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end

-- List Umi and Big Umi
s.listed_names={22702055,19712909} -- Umi and Big Umi

-- Cost: Discard this card
function s.searchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- Search filter
function s.searchfilter(c)
	return (c:IsCode(22702055) or c:IsCode(19712909)) and c:IsAbleToHand()
end

-- Target search
function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Perform search
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.searchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Condition: You control "Umi" or "Big Umi"
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and (c:IsCode(22702055) or c:IsCode(19712909))
	end,tp,LOCATION_ONFIELD,0,1,nil)
end

-- Cost: Discard 1 card
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Target draw
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Draw 1 card
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
