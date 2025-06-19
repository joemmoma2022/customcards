local s,id=GetID()
function s.initial_effect(c)
    -- Activate in response to a valid Kick card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Returns true if the card is Kick (0x1801), optionally Strike (0x0801),
-- but not Punch, Blast, Slash, or Final Strike
function s.isKickOnly(rc)
    return rc:IsSetCard(0x1801) -- Must be Kick
        and not rc:IsSetCard(0x3801) -- Not Punch
        and not rc:IsSetCard(0x5801) -- Not Blast
        and not rc:IsSetCard(0x4801) -- Not Slash
        and not rc:IsSetCard(0x6801) -- Not Final Strike
end

-- Only trigger if opponent activates valid Kick card
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp or not re then return false end
    local rc=re:GetHandler()
    return rc and s.isKickOnly(rc) and Duel.IsChainNegatable(ev)
end

-- Set negation info
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Negate activation and restrict future Kick activations this turn
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1) -- Opponent only
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)
end

-- Restriction applies only to cards that match isKickOnly
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return rc and s.isKickOnly(rc)
end
