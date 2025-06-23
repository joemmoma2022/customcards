local s,id=GetID()
local WEAK_TOKEN_ID=19712035

function s.initial_effect(c)
    -- Activation (pay 400 LP)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)

    -- Once per turn: Destroy 1 Weak Token your opponent controls, then burn
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Activation cost: Pay 400 LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,400) end
    Duel.PayLPCost(tp,400)
end

-- Target: 1 Weak Token on opponent's field
function s.tokenfilter(c)
    return c:IsFaceup() and c:IsCode(WEAK_TOKEN_ID) and c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tokenfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.tokenfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        -- Count remaining Weak Tokens after destruction
        local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_MZONE,nil,WEAK_TOKEN_ID)
        local count=#g
        if count>0 then
            Duel.Damage(1-tp,count*500,REASON_EFFECT)
        end
    end
end
