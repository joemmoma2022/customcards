--Fire Grimoire Continuous
local s,id=GetID()
local COUNTER_GRIMOIRE=0x8960
local GRIMOIRE_CARD_ID=1032017 -- Example Grimoire card exception

function s.initial_effect(c)
    -- Enable counters
    c:EnableCounterPermit(COUNTER_GRIMOIRE)

    -- Place itself face-up on the field at duel start
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_DECK)
    e1:SetCountLimit(1)
    e1:SetOperation(s.startup)
    c:RegisterEffect(e1)

    -- Standby Phase: add 1 Grimoire counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.counter_cond)
    e2:SetOperation(s.counter_op)
    c:RegisterEffect(e2)

    -- Ignition effect: remove counters to activate effect
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

-- Place itself face-up on the field at duel start
function s.startup(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_SZONE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
    Duel.Hint(HINT_CARD,tp,id)
end

-- Standby Phase condition: only your turn
function s.counter_cond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

-- Add 1 Grimoire Counter
function s.counter_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:AddCounter(COUNTER_GRIMOIRE,1)
        Duel.Hint(HINT_CARD,tp,id)
    end
end

-- Ignition target: check if at least 1 counter
function s.effect_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetCounter(COUNTER_GRIMOIRE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

-- Ignition operation: remove 1 counter and deal 500 damage
function s.effect_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(COUNTER_GRIMOIRE)<1 then return end
    c:RemoveCounter(tp,COUNTER_GRIMOIRE,1,REASON_EFFECT)
    Duel.Damage(1-tp,500,REASON_EFFECT)
end

-- Immune to all effects except Grimoire Cards and itself
function s.efilter(e,te)
    local tc=te:GetHandler()
    if not tc then return true end
    -- Allow effects from this card itself or Grimoire cards
    return tc~=e:GetHandler() and tc:GetCode()~=GRIMOIRE_CARD_ID
end
