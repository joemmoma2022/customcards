local s,id=GetID()
function s.initial_effect(c)
    -- (1) Activate this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- (2) Quick Effect: Send to GY to negate opponent's "Punch" card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- (2) Condition: Opponent activates a "Punch" card (SetCode 0x770), and it's negatable
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end -- Now checks if opponent is activating
    local rc=re:GetHandler()
    return rc:IsSetCard(0x3801) and Duel.IsChainDisablable(ev)
end

-- (2) Cost: Send this card to the GY
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- (2) Targeting info for negation
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

-- (2) Operation: Negate the activation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end
