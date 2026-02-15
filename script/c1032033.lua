--Fire Grimoire Continuous
local s,id=GetID()
local COUNTER_GRIMOIRE=0x8960
local GRIMOIRE_CARD_ID=1032017 -- Example Grimoire card exception

-- =============================
-- FUTUREPROOF CARD TABLE
-- Mana Cost -> {Card IDs}
-- Player chooses ONE from list
-- =============================
s.mana_rewards={
    [1]={10329037, 10329038} -- Fireball
    -- Example expansion:
    -- [1]={10329037,99999999,88888888}
}

function s.initial_effect(c)
    -- Enable counters
    c:EnableCounterPermit(COUNTER_GRIMOIRE)

    -- Draw Phase: move from Deck OR Hand to field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE+PHASE_DRAW)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_DECK+LOCATION_HAND)
    e1:SetCountLimit(1)
    e1:SetCondition(s.start_cond)
    e1:SetOperation(s.startup)
    c:RegisterEffect(e1)

    -- Standby Phase: add 1 Mana Point
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.counter_cond)
    e2:SetOperation(s.counter_op)
    c:RegisterEffect(e2)

    -- Ignition: Remove Mana Point to choose reward
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.effect_tg)
    e3:SetOperation(s.effect_op)
    c:RegisterEffect(e3)

    -- Immune to all card effects except Grimoire Cards and itself
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetValue(s.efilter)
    c:RegisterEffect(e4)
end

-- Only on your Draw Phase
function s.start_cond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

-- Move itself to S/T Zone, draw if from hand
function s.startup(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

    local from_hand=c:IsLocation(LOCATION_HAND)

    if not c:IsLocation(LOCATION_SZONE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        Duel.Hint(HINT_CARD,tp,id)

        -- Bonus draw if it came from hand
        if from_hand then
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- Standby Phase condition
function s.counter_cond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

-- Add 1 Mana Point
function s.counter_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(COUNTER_GRIMOIRE,1)
        Duel.Hint(HINT_CARD,tp,id)
    end
end

-- Must have at least 1 Mana Point and rewards available
function s.effect_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:GetCounter(COUNTER_GRIMOIRE)>0
            and s.mana_rewards[1]
            and #s.mana_rewards[1]>0
    end
end

-- Remove 1 Mana Point and choose ONE reward
function s.effect_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(COUNTER_GRIMOIRE)<1 then return end

    local rewards=s.mana_rewards[1]
    if not rewards then return end

    -- Build selection list
    local group=Group.CreateGroup()
    for _,cid in ipairs(rewards) do
        group:AddCard(Duel.CreateToken(tp,cid))
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=group:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
    if not tc then return end

    -- Pay cost
    c:RemoveCounter(tp,COUNTER_GRIMOIRE,1,REASON_EFFECT)

    -- Add chosen card
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,tc)
end

-- Immune to all effects except Grimoire Cards and itself
function s.efilter(e,te)
    local tc=te:GetHandler()
    if not tc then return true end
    return tc~=e:GetHandler() and tc:GetCode()~=GRIMOIRE_CARD_ID
end
