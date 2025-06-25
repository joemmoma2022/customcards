--Hope 1 (Quick-Play Version with Discard)
local s,id=GetID()
function s.initial_effect(c)
    -- Survive when LP would become 0 (during opponent's turn only)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(511002521) -- same custom event as original Hope 1
    e1:SetCondition(s.condition) -- Only during opponent's turn
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Global LP monitor to raise custom event when LP reaches 0
    aux.GlobalCheck(s,function()
        -- Prevent losing LP temporarily (needed to delay actual loss)
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

        -- Monitor LP every frame
        local ge3=Effect.CreateEffect(c)
        ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge3:SetCode(EVENT_ADJUST)
        ge3:SetOperation(s.op)
        Duel.RegisterEffect(ge3,0)
    end)
end

-- Condition: this version only works during the opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end

-- Condition for global LP lock
function s.con2(e)
    return Duel.GetFlagEffect(e:GetLabel(),511002521)>0
end

-- Raise custom event if LP is 0, and maintain flag
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

-- Cost: discard 1 card
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    -- Prevent LP loss this chain
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_CHAIN)
    e1:SetCode(EFFECT_CANNOT_LOSE_LP)
    Duel.RegisterEffect(e1,tp)
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Effect: Set your LP to 1
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetLP(tp,1,REASON_EFFECT)
end
