--Custom Kraken Protection Card
local s,id=GetID()
function s.initial_effect(c)
	-- This card is also treated as WATER
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e0)

	-- Protection and ATK modification while [L] or [R] is controlled
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.protcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.protcon)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)

	-- Set ATK to 4000 while [L] or [R] is on field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.protcon)
	e4:SetValue(4000)
	c:RegisterEffect(e4)
end

-- Condition: control L or R form
function s.protcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,19712935)
		or Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,19712936)
end

-- Value for indestructible effect (only effects that do NOT target)
function s.indval(e,re,rp)
	return not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
