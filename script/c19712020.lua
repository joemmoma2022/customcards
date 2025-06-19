local s,id=GetID()
function s.initial_effect(c)
    -- Quick effect: Negate and destroy a "Strike" card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Condition: Opponent activates a "Strike" card
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp 
        and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
        and re:GetHandler():IsSetCard(0x1801) 
        and Duel.IsChainNegatable(ev)
end

-- Set up negation and destruction
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

-- Execute negation and destruction
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
    local rc=re:GetHandler()
    if rc:IsRelateToEffect(re) then
        Duel.Destroy(rc,REASON_EFFECT)
    end
end
