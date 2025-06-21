local s,id=GetID()
function s.initial_effect(c)
    -- Battle indestructibility against high-ATK monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.indcon)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    -- Must be attacked if your opponent attacks a DARK Insect you control
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atklimitcon)
    e2:SetValue(s.atklimit)
    c:RegisterEffect(e2)
end

-- Condition: You control another DARK Insect monster
function s.indcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(s.otherdarkinsect,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.otherdarkinsect(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_INSECT)
end

-- Indestructible in battle vs monsters with 2000 or more ATK
function s.indval(e,c)
    return c:GetAttack()>=2000
end

-- Attack targeting restriction: must attack this card instead of other DARK Insects
function s.atklimitcon(e)
    return Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),RACE_INSECT)
end
function s.atklimit(e,c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_INSECT) and c~=e:GetHandler()
end
