local s,id=GetID()
local DEBUFF_ARC=0x8805

function s.initial_effect(c)
    -- Activate (pay 500 LP)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.actcost)
    c:RegisterEffect(e1)

    -- Pay 300 LP or destroy during your End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.lpcheckcon)
    e2:SetOperation(s.lpcheckop)
    c:RegisterEffect(e2)

    -- Damage trigger
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_DAMAGE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.con)
    e3:SetTarget(s.tg)
    e3:SetOperation(s.op)
    c:RegisterEffect(e3)
end

function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

function s.lpcheckcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

function s.lpcheckop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,300) then
        Duel.PayLPCost(tp,300)
    else
        Duel.Destroy(c,REASON_RULE)
    end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
    if ep==tp then return false end -- damage must be to opponent
    if (r & REASON_BATTLE) ~= 0 then return false end -- exclude battle damage
    if not re or not re:GetHandler() then return false end
    local rc=re:GetHandler()
    if not rc:IsSetCard(DEBUFF_ARC) then return false end -- must be Debuff archetype
    return true
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(300)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
