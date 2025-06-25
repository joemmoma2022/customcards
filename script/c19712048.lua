--Slash Ignition
local s,id=GetID()
local SEARING_BLOW_ID=19712049
local SLASH_ARC=0x9801

function s.initial_effect(c)
    -- Activate this card (Pay 500 LP)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.actcost)
    c:RegisterEffect(e1)

    -- Maintenance: Pay 400 LP during your End Phase or destroy this card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.mtcon)
    e2:SetOperation(s.mtop)
    c:RegisterEffect(e2)

    -- If you deal damage with a Slash card: Inflict 300 damage to opponent
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_DAMAGE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.damcon)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Once per turn: Add 1 "Searing Blow" from Deck to Hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.sbtg)
    e4:SetOperation(s.sbop)
    c:RegisterEffect(e4)
end

-- Activation cost
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

-- Maintenance cost condition: your End Phase
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp)
end

-- Pay 400 LP or destroy
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.CheckLPCost(tp,400) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.PayLPCost(tp,400)
    else
        Duel.Destroy(e:GetHandler(),REASON_COST)
    end
end

-- If you deal damage with a Slash card
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    if ep~=1-tp then return false end
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(SLASH_ARC) and rp==tp
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(300)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end

-- Search Searing Blow
function s.sbfilter(c)
    return c:IsCode(SEARING_BLOW_ID) and c:IsAbleToHand()
end

function s.sbtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sbfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.sbop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.sbfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
