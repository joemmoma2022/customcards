local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be negated except by specific cards
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_INACTIVATE)
    e0:SetValue(s.effectfilter)
    c:RegisterEffect(e0)
    
    -- Activation effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Only "Final Attack" or specific "Counter" cards can negate this
function s.effectfilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    local tc=te:GetHandler()
    return not (
        tc:IsSetCard(0x6801) or
        (tc:IsSetCard(0x0776) and s.textMentionsFinalAttack(tc))
    )
end

-- Checks if a card's text mentions "Final Attack" cards
function s.textMentionsFinalAttack(c)
    local code=c:GetOriginalCode()
    local tpe=c:GetType()
    local text=string.lower(Duel.GetCardEffectText(code))
    return text and string.find(text, "final attack")
end

-- Condition: Opponent must have 4000 or less LP
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(1-tp)<=4000
end

-- Cost: Banish all Strike cards from Deck and Hand
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    if chk==0 then return #g>0 end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.cfilter(c)
    return c:IsSetCard(0x3801) and c:IsAbleToRemoveAsCost()
end

-- Damage equal to opponent's current LP
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lp=Duel.GetLP(1-tp)
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(lp)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lp)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
