local s,id=GetID()
local BLEED_TOKEN_ID=19712041
local SLASH_ARC=0x9801
local FINAL_COUNTER_ARC=0x07766801

function s.initial_effect(c)
    -- Activate: Inflict damage equal to opponent's LP
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.actcon)
    e1:SetCost(s.actcost)
    e1:SetTarget(s.acttarget)
    e1:SetOperation(s.actoperation)
    -- Cannot be negated except by "Final Attack│Counter" archetype
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
    c:RegisterEffect(e1)
end

-- Activation condition: Opponent LP ≤ 3000 and 5+ Bleed Tokens on their field
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    local lp=Duel.GetLP(1-tp)
    local tokenCount=Duel.GetMatchingGroupCount(function(c) return c:IsCode(BLEED_TOKEN_ID) end,tp,0,LOCATION_MZONE,nil)
    return lp<=3000 and tokenCount>=5
end

-- Activation cost: Banish all "Slash" cards from Deck, Hand and GY
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    end
    local g=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.banishfilter(c)
    return c:IsSetCard(SLASH_ARC) and c:IsAbleToRemoveAsCost()
end

-- Target: Inflict damage equal to opponent LP
function s.acttarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(Duel.GetLP(1-tp))
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetLP(1-tp))
end

-- Operation: Inflict damage equal to opponent LP
function s.actoperation(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
