--Hope 1 (Quick-Play Version with Discard)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate as Quick-Play
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetHintTiming(0,TIMING_DAMAGE_STEP+TIMING_DAMAGE_CAL)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Global check to apply LP lock
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD)
        ge1:SetCode(EFFECT_CANNOT_LOSE_LP)
        ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ge1:SetTargetRange(1,0)
        ge1:SetLabel(0)
        ge1:SetCondition(s.con2)
        Duel.RegisterEffect(ge1,0)

        local ge2=ge1:Clone()
        ge2:SetLabel(1)
        Duel.RegisterEffect(ge2,1)

        local ge3=Effect.CreateEffect(c)
        ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge3:SetCode(EVENT_ADJUST)
        ge3:SetOperation(s.op)
        Duel.RegisterEffect(ge3,0)
    end)
end

-- Global LP lock condition
function s.con2(e)
    return Duel.GetFlagEffect(e:GetLabel(),511002521)>0
end

-- Maintain flag for LP tracking
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if Duel.GetLP(0)<=0 and ph~=PHASE_DAMAGE then
        Duel.RaiseEvent(Duel.GetMatchingGroup(nil,0,LOCATION_ONFIELD,0,nil),511002521,e,0,0,0,0)
        Duel.ResetFlagEffect(0,511002521)
    end
    if Duel.GetLP(1)<=0 and ph~=PHASE_DAMAGE then
        Duel.RaiseEvent(Duel.GetMatchingGroup(nil,1,LOCATION_ONFIELD,0,nil),511002521,e,0,0,0,0)
        Duel.ResetFlagEffect(1,511002521)
    end
    if Duel.GetLP(0)>0 and Duel.GetFlagEffect(0,511002521)==0 then
        Duel.RegisterFlagEffect(0,511002521,0,0,1)
    end
    if Duel.GetLP(1)>0 and Duel.GetFlagEffect(1,511002521)==0 then
        Duel.RegisterFlagEffect(1,511002521,0,0,1)
    end
end

-- New cost: discard 1 card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Set LP to 1
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetLP(tp,1,REASON_EFFECT)
end
