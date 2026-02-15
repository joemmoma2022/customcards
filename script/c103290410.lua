--Healing Spore
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon Restriction: can only be Special Summoned by "Healing Spores" spell
    c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(function(e,se,sp,st)
        return se and se:GetHandler():IsCode(10329051)
    end)
    c:RegisterEffect(e0)

    -- Cannot leave the field except by being banished
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1)

    -- Gain LP when destroyed (battle or card effect)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCondition(s.lpcon)
    e2:SetTarget(s.lptg)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)
end

-- Condition: destroyed by battle or card effect
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

-- Target: gain 125 LP
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(125)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,125)
end

-- Operation: gain LP
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
