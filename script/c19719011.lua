local s,id=GetID()
local COUNTER_BOSS_ACTION=0x2319 -- still declared for compatibility

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_BOSS_ACTION)

    -- This card is unaffected by other card effects
    local e_immune=Effect.CreateEffect(c)
    e_immune:SetType(EFFECT_TYPE_SINGLE)
    e_immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e_immune:SetRange(LOCATION_SZONE)
    e_immune:SetCode(EFFECT_IMMUNE_EFFECT)
    e_immune:SetValue(s.efilter)
    c:RegisterEffect(e_immune)

    -- Passive shuffle non-monster GY cards into Deck at your Draw Phase if deck is empty
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_PREDRAW)
    e0:SetRange(LOCATION_SZONE)
    e0:SetCondition(s.shufflecon)
    e0:SetOperation(s.shuffleop)
    c:RegisterEffect(e0)

    -- Once per turn: add 1 card from deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

function s.efilter(e,re)
    return re:GetOwner()~=e:GetOwner()
end

-- Condition: Your turn, before draw, deck is empty, and you have non-monster cards in GY
function s.shufflecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0
        and Duel.GetMatchingGroupCount(function(c) return not c:IsType(TYPE_MONSTER) end,tp,LOCATION_GRAVE,0,nil)>0
end

-- Operation: Shuffle non-monster cards from GY into Deck
function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return not c:IsType(TYPE_MONSTER) end,tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
