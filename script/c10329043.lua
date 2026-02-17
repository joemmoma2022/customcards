local s,id=GetID()
function s.initial_effect(c)
	--Activate from hand (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- LP cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end

-- Filter for any face-up card
function s.filter(c)
	return c:IsFaceup()
end

-- Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

-- Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- Banish this card after resolution
	if c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
	end
end
