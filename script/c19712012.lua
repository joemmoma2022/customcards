local s,id=GetID()

function s.initial_effect(c)
    -- Activate (only at start of Main Phase 1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Only at the start of Main Phase 1, and no prior activity
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsPhase(PHASE_MAIN1) and not Duel.CheckPhaseActivity()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local turn=Duel.GetTurnCount()

    -- No damage during opponent's next turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.damval)
    e1:SetLabel(turn)
    e1:SetCondition(s.damcon)
    Duel.RegisterEffect(e1,tp)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(e2,tp)

    -- Lock player from activating any other cards this turn
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetValue(s.aclimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
end

function s.damval(e,re,val,r,rp,rc)
    return 0
end

function s.damcon(e)
    -- Damage protection only on opponent's next turn
    return Duel.GetTurnPlayer()~=e:GetOwnerPlayer() and Duel.GetTurnCount()==e:GetLabel()+1
end

function s.aclimit(e,re,tp)
    return true
end
