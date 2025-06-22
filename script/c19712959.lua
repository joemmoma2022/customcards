--Cookpal Memorial Banquet
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Attach "Cookpal" monsters sent to GY this turn, then add that many from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Once per turn: send 1 underneath monster to GY to add 1 "Cookpal" or "Royal Cookpal" from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-- Destroy this card if you control more monsters than attached cards
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

s.listed_series={0x512, 0x1512} -- "Cookpal" and "Royal Cookpal"

-- Filter: "Cookpal" monsters sent to GY this turn (excluding returned cards)
function s.cfilter(c,tid)
	return c:IsSetCard(0x512) and c:IsMonster() and c:GetTurnID()==tid and not c:IsReason(REASON_RETURN)
end

-- Filter: Searchable "Cookpal" monsters in Deck
function s.thfilter(c)
	return c:IsSetCard(0x512) and c:IsMonster() and c:IsAbleToHand()
end

-- Filter: "Cookpal" or "Royal Cookpal" in GY for recovery
function s.gyfilter(c)
	return c:IsMonster() and (c:IsSetCard(0x512) or c:IsSetCard(0x1512)) and c:IsAbleToHand()
end

-- Target for activation
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,Duel.GetTurnCount())
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end

-- Operation: Overlay and search
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,Duel.GetTurnCount())
	if #g>0 then
		Duel.Overlay(c,g)
		local ct=c:GetOverlayCount()
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
			if #g2>0 then
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
end

-- GY Recovery Target
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetOverlayCount()>0 and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

-- GY Recovery Operation
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetOverlayCount()==0 then return end
	local og=c:GetOverlayGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local tc=og:Select(tp,1,1,nil):GetFirst()
	if tc then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- Destroy if monster count exceeds overlay count
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>c:GetOverlayCount() then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Destroy(c,REASON_EFFECT)
	end
end
