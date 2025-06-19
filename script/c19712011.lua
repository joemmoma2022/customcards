local s,id=GetID()
function s.initial_effect(c)
    -- Activate this card
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Boost effect damage from Punch/Kick Spell Cards by 500
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1) -- Opponent takes boosted damage
    e1:SetValue(s.damval)
    c:RegisterEffect(e1)

    -- Maintenance: Pay 500 LP during your Standby Phase or destroy this card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e2:SetProperty(EFFECT_FLAG_REPEAT)
    e2:SetCondition(s.paycon)
    e2:SetOperation(s.payop)
    c:RegisterEffect(e2)
end

-- Increase damage only during Punch/Kick Spell effects
function s.damval(e,re,val,r,rp)
    if val <= 0 then return val end
    if not re or not re:GetHandler() then return val end
    local rc = re:GetHandler()
    if rc:IsType(TYPE_SPELL) and rc:IsControler(e:GetHandler():GetControler())
        and (rc:IsSetCard(0x0801) and not rc:IsSetCard(0x6801)) then
        return val + 500
    end
    return val
end

-- Only during your Standby Phase
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer() == tp
end

-- Pay 500 LP or destroy this card
function s.payop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,700) and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
        Duel.PayLPCost(tp,700)
    else
        Duel.Destroy(c,REASON_COST)
    end
end
