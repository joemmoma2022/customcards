local s,id=GetID()
function s.initial_effect(c)
    -- Activate by paying 200 LP
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)

    -- Once per turn: Place a "Block" Continuous Spell from Deck or GY face-up on the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- Maintenance: Pay 200 LP during your Standby Phase or destroy this card
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e3:SetProperty(EFFECT_FLAG_REPEAT)
    e3:SetCondition(s.paycon)
    e3:SetOperation(s.payop)
    c:RegisterEffect(e3)
end

-- Activation cost: pay 200 LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,200) end
    Duel.PayLPCost(tp,200)
end

-- Filter for "Block" Continuous Spells
function s.filter(c)
    return c:IsSetCard(0x772) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end

-- Target to place "Block" Continuous Spell
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end

-- Operation: Place selected "Block" Continuous Spell face-up
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        Duel.ConfirmCards(1-tp,tc)
    end
end

-- Only during your Standby Phase
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

-- Pay 200 LP or destroy this card
function s.payop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,200) and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
        Duel.PayLPCost(tp,200)
    else
        Duel.Destroy(c,REASON_COST)
    end
end
