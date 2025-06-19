local s,id=GetID()
function s.initial_effect(c)
    -- Activation condition: You take damage from opponent's card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetCondition(s.actcon)
    c:RegisterEffect(e1)

    -- Continuous effect: Burn opponent for 100 when you take damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end

-- Activation only if you took damage from opponent's card
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and rp==1-tp
end

-- Trigger while face-up: if you take damage from opponent
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and rp==1-tp
end

-- Inflict 100 damage to opponent
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,100,REASON_EFFECT)
end
