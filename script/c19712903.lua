local s,id=GetID()
local CARD_UMI=22702055
local BIG_UMI=19712909

function s.initial_effect(c)
	-- Special Summon from hand by tributing 1 WATER monster if "Umi" or "Big Umi" is on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Gain 300 ATK per WATER monster on the field except itself
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Send 1 WATER you control to GY; debuff 1 opponent monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_UMI,BIG_UMI}

-- Check if "Umi" or "Big Umi" is face-up on the field
function s.umifilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_UMI) or c:IsCode(BIG_UMI))
end

-- Special Summon condition: Umi or Big Umi on field + tributing 1 WATER monster
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.umifilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end

-- Special Summon operation: tribute 1 WATER monster
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WATER)
	Duel.Release(g,REASON_COST)
end

-- ATK gain: 300 × WATER monsters excluding this card
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(function(tc) return tc:IsAttribute(ATTRIBUTE_WATER) and tc~=c end,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetCount()*300
end

-- Cost: Send 1 WATER monster you control (not self)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(function(tc) return tc:IsAttribute(ATTRIBUTE_WATER) and tc:IsAbleToGraveAsCost() and tc~=e:GetHandler() end,tp,LOCATION_MZONE,0,1,nil) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,function(tc) return tc:IsAttribute(ATTRIBUTE_WATER) and tc:IsAbleToGraveAsCost() and tc~=e:GetHandler() end,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Target opponent's monster
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

-- Debuff: -100 ATK per WATER on field (except this card)
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(function(tc) return tc:IsAttribute(ATTRIBUTE_WATER) and tc~=c end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local atkdown=g:GetCount()*100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atkdown)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
