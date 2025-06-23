local s,id=GetID()
function s.initial_effect(c)
    -- Burn 100 damage during controller's Standby Phase (forced trigger)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- optional description
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    -- Trigger only on token controller's Standby Phase
    return Duel.GetTurnPlayer()==tp
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)  -- Damage token controller
    Duel.SetTargetParam(100)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,100)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
