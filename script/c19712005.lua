local s,id=GetID()
function s.initial_effect(c)
    --Activate: Pay 200 LP cost, then deal 700 damage to opponent & lock "Block" cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Pay 200 LP as cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,200) end
    Duel.PayLPCost(tp,200)
end

--Targeting: always valid, set damage info
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(700)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end

--Activate: deal 700 damage + lock "Block" cards
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p1=tp
    local p2=1-tp
    --Deal 700 damage to opponent
    Duel.Damage(p2,700,REASON_EFFECT)
    --Apply "Block" lock effect for both players
    s.blocklock(e:GetHandler(),p1)
    s.blocklock(e:GetHandler(),p2)
end

--Prevent "Block" cards from being activated or having their effects trigger
function s.blocklock(c,p)
    --Prevent activating "Block" cards (from hand, field, GY, etc.)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1,0)
    e1:SetValue(function(e,re,tp)
        local rc=re:GetHandler()
        return rc:IsSetCard(0x772) and rc:IsType(TYPE_SPELL) and rc:IsType(TYPE_CONTINUOUS)
    end)
    e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
    Duel.RegisterEffect(e1,p)

    --Prevent setting "Block" cards
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_SSET)
    e2:SetTarget(function(_e,sc)
        return sc:IsSetCard(0x772) and sc:IsType(TYPE_SPELL) and sc:IsType(TYPE_CONTINUOUS)
    end)
    Duel.RegisterEffect(e2,p)

    --Prevent triggering effects of "Block" cards already on the field
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_TRIGGER)
    e3:SetTargetRange(1,0)
    e3:SetTarget(function(_e,te,tp)
        local rc=te:GetHandler()
        return rc:IsSetCard(0x772) and rc:IsType(TYPE_SPELL) and rc:IsType(TYPE_CONTINUOUS)
    end)
    e3:SetReset(RESET_PHASE+PHASE_STANDBY,2)
    Duel.RegisterEffect(e3,p)
end
