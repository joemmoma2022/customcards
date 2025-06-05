local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,1,false,nil,nil,1)

    -- Start-of-duel flip and add cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetOperation(s.startupop)
    c:RegisterEffect(e1)

    -- Continuous effect: Burn both players 500 LP if LP ≤ 2000
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SKILL)
    e2:SetCountLimit(1)
    e2:SetCondition(s.burncon)
    e2:SetOperation(s.burnop)
    c:RegisterEffect(e2)

    -- Continuous effect: Make all your T.G. monsters BEAST and MACHINE race
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_ADD_RACE)
    e3:SetRange(LOCATION_SKILL)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.racetg)
    e3:SetValue(RACE_BEAST+RACE_MACHINE)
    c:RegisterEffect(e3)

    -- Ignition effect: Once per turn add Rabbit or Tank counter on Rabbittank
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SKILL)
    e4:SetCountLimit(1)
    e4:SetCondition(s.counter_condition)
    e4:SetOperation(s.counter_operation)
    c:RegisterEffect(e4)
end

-- Add cards at start of duel
function s.startupop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)

    -- Create tokens for Rabbit, Tank, Rabbittank
    local rabbit = Duel.CreateToken(tp,19712856)    -- Rabbit card ID (replace with your actual IDs)
    local tank = Duel.CreateToken(tp,19712857)      -- Tank card ID
    local rabbittank = Duel.CreateToken(tp,19712858) -- Rabbittank card ID

    -- Add Rabbit and Tank to hand
    if rabbit then Duel.SendtoHand(rabbit,nil,REASON_RULE) end
    if tank then Duel.SendtoHand(tank,nil,REASON_RULE) end
    Duel.ShuffleHand(tp)

    -- Add Rabbittank to Extra Deck
    if rabbittank then Duel.SendtoDeck(rabbittank,nil,SEQ_DECKTOP,REASON_RULE) end
end

-- Condition to burn LP if ≤ 2000
function s.burncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp) <= 2000 or Duel.GetLP(1-tp) <= 2000
end

-- Burn 500 LP to both players
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    if Duel.GetLP(tp) <= 2000 then Duel.Damage(tp,500,REASON_RULE) end
    if Duel.GetLP(1-tp) <= 2000 then Duel.Damage(1-tp,500,REASON_RULE) end
end

-- Target filter: all your face-up T.G. monsters
function s.racetg(e,c)
    return c:IsFaceup() and c:IsSetCard(0x27)
end

-- Filter Rabbittank for counter placement
function s.counter_filter(c)
    return c:IsFaceup() and c:IsCode(19712858) 
       and (c:IsCanAddCounter(0x111f,1) or c:IsCanAddCounter(0x1120,1))
end

-- Condition to activate counter placement ignition effect
function s.counter_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.counter_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- Operation: Add Rabbit or Tank counter on Rabbittank
function s.counter_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)

    local g=Duel.GetMatchingGroup(s.counter_filter,tp,LOCATION_MZONE,0,nil)
    if #g == 0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc = g:Select(tp,1,1,nil):GetFirst()

    local canAddRabbit = tc:IsCanAddCounter(0x111f,1)
    local canAddTank = tc:IsCanAddCounter(0x1120,1)

    local sel=0
    if canAddRabbit and canAddTank then
        sel = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif canAddRabbit then
        sel = 0
    elseif canAddTank then
        sel = 1
    else
        return
    end

    if sel == 0 then
        tc:AddCounter(0x111f,1)
        Duel.Hint(HINT_MESSAGE,tp,"Added Rabbit Counter")
    else
        tc:AddCounter(0x1120,1)
        Duel.Hint(HINT_MESSAGE,tp,"Added Tank Counter")
    end
end
