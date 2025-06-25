local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be negated except by "Final Counter" cards
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

-- Only "Final Counter" cards can negate this card's activation
function s.effectfilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    if not te then return true end
    local tc=te:GetHandler()
    return not s.isFinalCounter(tc)
end

-- Check if the card is a "Final Counter" card
function s.isFinalCounter(c)
    return c:IsSetCard(0x6801) or (c:IsSetCard(0x0776) and s.textMentionsFinalAttack(c))
end

-- Check if card text contains "Final Attack"
function s.textMentionsFinalAttack(c)
    local code=c:GetOriginalCode()
    local tpe=c:GetType()
    -- Fallback for effect-less cards
    local ce={Duel.GetCardEffect(code)}
    for _,e in ipairs(ce) do
        local desc=e:GetDescription()
        if desc and string.find(string.lower(desc),"final attack") then
            return true
        end
    end
    return false
end

-- Condition: Opponent must have 4000 or less LP
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(1-tp)<=4000
end

-- Cost: Banish all "Strike" cards from Deck and Hand
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    if chk==0 then return #g>0 end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.cfilter(c)
    return c:IsSetCard(0x0801) and c:IsAbleToRemoveAsCost()
end

-- Target: Deal damage equal to opponent's current LP
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
