local s,id=GetID()
function s.initial_effect(c)
    --Persistent procedure: target 1 opponent's monster
    aux.AddPersistentProcedure(c,nil,s.filter,CATEGORY_DISABLE,nil,nil,TIMINGS_CHECK_MONSTER,nil,nil,s.target)

    --Disable effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(aux.PersistentTargetFilter)
    c:RegisterEffect(e1)

    --Cannot attack
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e2)

    --Cannot change battle position
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(e3)

    --Destroy when targeted monster leaves the field
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.descon)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)

    --Banish if this card leaves the field
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e5)
end

--Filter: face-up monster (no restrictions)
function s.filter(c)
    return c:IsFaceup()
end

--Target procedure
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end

--Destroy condition: target leaves the field
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
    local tc=c:GetFirstCardTarget()
    return tc and eg:IsContains(tc) and not tc:IsOnField()
end

--Destroy this card
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
