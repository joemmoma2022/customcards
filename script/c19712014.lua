local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

-- Condition: Opponent activates a "Strike" card (SetCode 0x0801), but not a "Final Attack" (SetCode 0x9707)
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp or not Duel.IsChainDisablable(ev) then return false end
    local rc=re:GetHandler()
    return rc:IsSetCard(0x0801) and not rc:IsSetCard(0x6801)
end

-- Target for negation and damage
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end

-- Operation: Negate and deal damage
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    end
end