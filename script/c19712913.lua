local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if "Big Umi" or "Umi" on field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

	-- Tribute 1 WATER monster except this card; shuffle 1 opponent's monster into Deck; no direct attacks this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={19712909,22702055} -- Big Umi and Umi

-- Check for "Big Umi" or "Umi" on field
function s.umifilter(c)
	return c:IsFaceup() and (c:IsCode(19712909) or c:IsCode(22702055))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

-- Tribute 1 WATER monster except this card as cost
function s.costfilter(c,e)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsReleasable() and not c:IsCode(e:GetHandler():GetCode())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e) end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e)
	Duel.Release(g,REASON_COST)
end

-- Target opponent's monster to shuffle into Deck
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

-- Operation: shuffle targeted monster into Deck and apply no direct attacks effect
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- Cannot attack directly this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
