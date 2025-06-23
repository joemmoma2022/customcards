--Weak Token
local s,id=GetID()

function s.initial_effect(c)
    -- Register summon turn label when token is summoned
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regturn)
    c:RegisterEffect(e0)
    
    -- Destroy during your opponent's next End Phase after summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.descon)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Halve any effect damage to token controller's opponent (you)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1) -- token controller's opponent
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
end

function s.regturn(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Store the turn count when the token was summoned
    c:SetTurnCounter(Duel.GetTurnCount())
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local current_turn=Duel.GetTurnCount()
    local summon_turn=c:GetTurnCounter()
    -- Destroy at opponent's End Phase if current turn > summon turn
    return Duel.GetTurnPlayer()~=tp and current_turn > summon_turn
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.damval(e,re,val,r,rp,rc)
    if bit.band(r,REASON_EFFECT)~=0 then -- halve all effect damage regardless of source
        return math.floor(val/2)
    end
    return val
end
