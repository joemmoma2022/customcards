local s,id=GetID()
local SEARING_BLOW_ID=19712049
local SLASH_ARC=0x9801

function s.initial_effect(c)
    -- Activation cost: pay 500 LP
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCost(s.actcost)
    c:RegisterEffect(e0)

    -- Maintenance cost: pay 400 LP during your End Phase or destroy this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.paycon)
    e1:SetOperation(s.payop)
    c:RegisterEffect(e1)

    -- Damage trigger: each time you deal damage with a "Slash" card, inflict 300 damage to opponent
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.damcon)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    -- Once per turn: add 1 "Searing Blow" from Deck to hand; if activated this turn, take 300 damage
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.sbtg)
    e3:SetOperation(s.sbop)
    c:RegisterEffect(e3)

    -- Track if "Searing Blow" was activated this turn
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetOperation(s.checkchain)
    c:RegisterEffect(e4)

    -- Reset flag at end phase
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_SZONE)
    e5:SetOperation(s.resetflag)
    c:RegisterEffect(e5)
end

function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

function s.paycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

function s.payop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,400) then
        Duel.PayLPCost(tp,400)
    else
        Duel.Destroy(c,REASON_RULE)
    end
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    if ep~=1-tp then return false end
    if not re or not re:GetHandler() then return false end
    local rc=re:GetHandler()
    return rc:IsSetCard(SLASH_ARC) and rp==tp
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

-- Track activation of "Searing Blow"
function s.checkchain(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if rc and rc:IsCode(SEARING_BLOW_ID) then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

function s.sbtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sbfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.sbfilter(c)
    return c:IsCode(SEARING_BLOW_ID) and c:IsAbleToHand()
end

function s.sbop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.sbfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
        Duel.ConfirmCards(1-tp,g)
        -- If "Searing Blow" was activated this turn, take 300 damage
        if e:GetHandler():GetFlagEffect(id)>0 then
            Duel.Damage(tp,300,REASON_EFFECT)
        end
    end
end

function s.resetflag(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():ResetFlagEffect(id)
end
