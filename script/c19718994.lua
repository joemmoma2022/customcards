local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,1,false,nil,nil,1)

    -- Start-of-duel flip and initial setup
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetOperation(s.startupop)
    c:RegisterEffect(e1)
end

function s.startupop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)

    -- Create and add cards to appropriate places
    local card1=Duel.CreateToken(tp,19712844) -- Example: "Risen"
    local card2=Duel.CreateToken(tp,19712845) -- Example: "Justice"
    local card3=Duel.CreateToken(tp,19712846) -- Example: "Vengeance"

    -- Add card1 (Risen) to Extra Deck
    if card1 then
        Duel.SendtoDeck(card1,nil,SEQ_DECKTOP,REASON_RULE)
    end

    -- Add card2 (Justice) to hand
    if card2 then
        Duel.SendtoHand(card2,nil,REASON_RULE)
    end

    -- Add card3 (Vengeance) to hand
    if card3 then
        Duel.SendtoHand(card3,nil,REASON_RULE)
    end

    Duel.ShuffleHand(tp)

    -- Register the once-per-turn counter placement effect
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1)
    e2:SetCondition(s.counter_condition)
    e2:SetOperation(s.counter_operation)
    Duel.RegisterEffect(e2,tp)
end

-- Filter face-up T.G. Striker RabbitTank monsters that can receive Rabbit or Tank counters
function s.counter_filter(c)
    return c:IsFaceup() and c:IsCode(19712858)
       and (c:IsCanAddCounter(0x111f,1) or c:IsCanAddCounter(0x1120,1))
end

-- Condition for activating the counter effect
function s.counter_condition(e,tp,eg,ep,ev,re,r,rp)
    return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.counter_filter,tp,LOCATION_MZONE,0,1,nil)
end

-- Operation: prompt to add either Rabbit or Tank counter to a chosen valid monster
function s.counter_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)

    local g=Duel.GetMatchingGroup(s.counter_filter,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=g:Select(tp,1,1,nil):GetFirst()

    local canAddRabbit = tc:IsCanAddCounter(0x111f,1)
    local canAddTank = tc:IsCanAddCounter(0x1120,1)

    local sel=0
    if canAddRabbit and canAddTank then
        sel=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif canAddRabbit then
        sel=0
    elseif canAddTank then
        sel=1
    else
        return
    end

    if sel==0 then
        tc:AddCounter(0x111f,1)
        Duel.Hint(HINT_MESSAGE,tp,"Added Rabbit Counter")
    else
        tc:AddCounter(0x1120,1)
        Duel.Hint(HINT_MESSAGE,tp,"Added Tank Counter")
    end
end
