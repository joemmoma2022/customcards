--Custom Kraken Support Monster
local s,id=GetID()
function s.initial_effect(c)
	-- Also treated as WATER Attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e0)

	-- Auto-banish self if "Abyss Kraken" is not on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.check_banish)
	c:RegisterEffect(e1)

	-- Once per turn: shuffle opponent’s 0 ATK monster into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)

	-- Inflict 500 damage when this card leaves your field
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.leaveop)
	c:RegisterEffect(e3)

	-- Once per turn, cannot be destroyed by card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(1)
	e4:SetValue(s.indct)
	c:RegisterEffect(e4)
end

-- Banish self if Kraken Main is not present
function s.krakenfilter(c)
	return c:IsFaceup() and c:IsCode(19712934)
end
function s.check_banish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(s.krakenfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and c:IsOnField() then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end

-- Shuffle opponent's 0 ATK monster into the Deck
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAttack(0) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

		local g=Duel.GetMatchingGroup(s.krakenRfilter,tp,LOCATION_MZONE,0,nil)
		for kr in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			kr:RegisterEffect(e1)
		end
	end
end
function s.krakenRfilter(c)
	return c:IsFaceup() and c:IsCode(19712936)
end

-- Inflict 500 damage when this leaves your field
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end

-- Once per turn indestructible by card effects
function s.indct(e,re,r,rp)
	return (r & REASON_EFFECT) ~= 0
end
