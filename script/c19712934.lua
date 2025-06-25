-- Custom Kraken Protection Card
local s,id=GetID()
function s.initial_effect(c)
    -- This card is also treated as WATER
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_ATTRIBUTE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(ATTRIBUTE_WATER)
    c:RegisterEffect(e0)

    -- Cannot be targeted by opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.krakencon) -- [L] or [R] check
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Cannot be selected as attack target
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.krakencon)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)

    -- Cannot be destroyed by battle (only while [L] or [R] is present)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.krakencon)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Cannot be destroyed by non-targeting effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.krakencon)
    e4:SetValue(s.indval)
    c:RegisterEffect(e4)

    -- ATK becomes 4000
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_SET_ATTACK)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.krakencon)
    e5:SetValue(4000)
    c:RegisterEffect(e5)
end

-- Condition: control "Abyss Kraken [L]" or "Abyss Kraken [R]"
function s.krakencon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19712935)
        or Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19712936)
end

-- Immune to non-targeting effects
function s.indval(e,re,tp)
    return not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
