--Custom Abyss Kraken Minion
local s,id=GetID()
function s.initial_effect(c)
	-- Also treated as WATER Attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e0)

	-- Auto-banish self if "Abyss Kraken Main" is not on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.check_banish)
	c:RegisterEffect(e1)

	-- Once per turn: Reduce this card's ATK, opponent's monsters lose same
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
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
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
end

-- Banish if Kraken Main is not on the field
function s.krakenfilter(c)
	return c:IsFaceup() and c:IsCode(19712934) -- Abyss Kraken Main
end
function s.check_banish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(s.krakenfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and c:IsOnField() then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end

-- ATK reduction effect
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttack()>=100 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetAttack()<100 then return end
	Duel.Hint(HINT_NUMBER,tp,100)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local maxAtk = math.floor(c:GetAttack()/100)*100
	local vals = {}
	for i=100,maxAtk,100 do table.insert(vals,i) end
	local val=Duel.AnnounceNumber(tp,table.unpack(vals))
	if not val or val<=0 then return end

	-- Reduce own ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)

	-- Reduce opponent's monsters' ATK
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-val)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e2)
	end
end

-- Inflict 500 damage when this card leaves your field
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) then
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end

-- Destruction prevention (by effects) once per turn
function s.indval(e,re,r,rp)
	return (r & REASON_EFFECT) ~= 0
end
