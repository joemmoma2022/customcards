local s,id=GetID()
local BLEED_TOKEN_ID=19712041
local SLASH_ARC=0x9801

function s.initial_effect(c)
    -- Activation cost: pay 300 LP
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCost(s.actcost)
    c:RegisterEffect(e0)
    
    -- Pay 300 LP or destroy during End Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.lpcheckcon)
    e1:SetOperation(s.lpcheckop)
    c:RegisterEffect(e1)
    
    -- When you inflict damage with a Slash card, deal 200 damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
    
    -- During your Standby Phase, destroy opponent's 3+ Bleed Tokens, deal 500 damage each
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.standbycon)
    e3:SetTarget(s.standbytg)
    e3:SetOperation(s.standbyop)
    c:RegisterEffect(e3)
end

-- Pay 300 LP cost to activate
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,300) end
    Duel.PayLPCost(tp,300)
end

-- During your End Phase, must pay 300 LP or destroy this card
function s.lpcheckcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.CheckLPCost(tp,300)==false
end

function s.lpcheckop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,300) then
        Duel.PayLPCost(tp,300)
    else
        Duel.Destroy(c,REASON_RULE)
    end
end

-- Check damage from your Slash cards
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    -- Damage must be inflicted to opponent by your Slash card effect or battle
    return ep==1-tp and re and re:GetHandler():IsSetCard(SLASH_ARC) and (r&REASON_EFFECT+REASON_BATTLE)~=0 and rp==tp
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,200,REASON_EFFECT)
end

-- Standby Phase condition (your Standby)
function s.standbycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.bleedfilter,tp,0,LOCATION_MZONE,3,nil)
end

function s.bleedfilter(c)
    return c:IsCode(BLEED_TOKEN_ID)
end

function s.standbytg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.bleedfilter,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return #g>=3 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end

function s.standbyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.bleedfilter,tp,0,LOCATION_MZONE,nil)
    if #g>=3 then
        local ct=Duel.Destroy(g,REASON_EFFECT)
        if ct>0 then
            Duel.Damage(1-tp,ct*500,REASON_EFFECT)
        end
    end
end
