local s,id=GetID()
function s.initial_effect(c)
	-- Equip opponent's monster once per turn and draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	-- Return equipped monster when this card leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.retoper)
	c:RegisterEffect(e2)

	-- Equip limit: only opponent's monster can be equipped to this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(s.eqlimit)
	c:RegisterEffect(e3)
end
s.listed_names={19712909,22702055} -- Big Umi and Umi

-- Condition: "Big Umi" or "Umi" is face-up on the field
function s.umifilter(c)
	return c:IsFaceup() and (c:IsCode(19712909) or c:IsCode(22702055))
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

-- Target opponent's monster to equip
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Equip operation and draw
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		if Duel.Equip(tp,tc,c) then
			-- Draw 1 card
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

-- Equip limit: only equips opponent's monster to this card
function s.eqlimit(e,c)
	return e:GetOwner()==c:GetEquipTarget()
end

-- Return equipped monster to opponent's field when this card leaves field
function s.retoper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_SZONE) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- Special summon it back to opponent's field
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
		else
			-- If no space, send to graveyard as fallback
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
