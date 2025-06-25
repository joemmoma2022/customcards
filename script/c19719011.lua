local s,id=GetID()
local COUNTER_BOSS_ACTION=0x2319

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

    -- Skip your Draw Phase
    local e_skip=Effect.CreateEffect(c)
    e_skip:SetType(EFFECT_TYPE_FIELD)
    e_skip:SetCode(EFFECT_SKIP_DP)
    e_skip:SetRange(LOCATION_SZONE)
    e_skip:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_skip:SetTargetRange(1,0)
    c:RegisterEffect(e_skip)

    -- During your Standby Phase: shuffle your hand into Deck
    local e_shufflehand=Effect.CreateEffect(c)
    e_shufflehand:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e_shufflehand:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e_shufflehand:SetRange(LOCATION_SZONE)
    e_shufflehand:SetCountLimit(1)
    e_shufflehand:SetCondition(function(e,tp,_,_,_,_,_) return Duel.GetTurnPlayer()==tp end)
    e_shufflehand:SetOperation(s.handshuffle_op)
    c:RegisterEffect(e_shufflehand)

    -- During opponent's End Phase: shuffle non-monsters from GY if Deck is empty
    local e_gyeffect=Effect.CreateEffect(c)
    e_gyeffect:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e_gyeffect:SetCode(EVENT_PHASE+PHASE_END)
    e_gyeffect:SetRange(LOCATION_SZONE)
    e_gyeffect:SetCondition(s.shufflegy_con)
    e_gyeffect:SetOperation(s.shufflegy_op)
    c:RegisterEffect(e_gyeffect)

    -- Once per turn: Add 1 card from Deck to hand
    local e_search=Effect.CreateEffect(c)
    e_search:SetDescription(aux.Stringid(id,0))
    e_search:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e_search:SetType(EFFECT_TYPE_IGNITION)
    e_search:SetRange(LOCATION_SZONE)
    e_search:SetCountLimit(1)
    e_search:SetTarget(s.thtg)
    e_search:SetOperation(s.thop)
    c:RegisterEffect(e_search)
end

function s.efilter(e,re)
    return re:GetOwner()~=e:GetOwner()
end

-- Shuffle hand into Deck during Standby Phase
function s.handshuffle_op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end

-- Opponent's End Phase condition
function s.shufflegy_con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0
        and Duel.IsExistingMatchingCard(s.nonmonsterfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- Shuffle non-monster GY cards into Deck
function s.shufflegy_op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.nonmonsterfilter,tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end

function s.nonmonsterfilter(c)
    return not c:IsType(TYPE_MONSTER)
end

-- Search effect
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
