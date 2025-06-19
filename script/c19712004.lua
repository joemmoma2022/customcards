local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Discard all "Punch" cards in hand to burn opponent
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Target check
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
    if chk==0 then return #g > 0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*700)
end

-- Filter: Punch archetype cards in hand
function s.filter(c)
    return c:IsSetCard(0x3801) and c:IsDiscardable()
end

-- Activation: Discard all Punch cards and inflict damage
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
    local count = #g
    if count == 0 then return end
    Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
    Duel.Damage(1-tp, count * 700, REASON_EFFECT)
end
