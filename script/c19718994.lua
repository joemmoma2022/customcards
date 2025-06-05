--T.G. Evolution Drive (Skill Card)
local s,id=GetID()
function s.initial_effect(c)
    -- Flip and activate at the start of the Duel (before Draw Phase)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCountLimit(1)
    e1:SetCondition(s.flipcon)
    e1:SetOperation(s.flipop)
    Duel.RegisterEffect(e1,0)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==1 and Duel.GetTurnPlayer()==tp
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SKILL_FLIP,tp,id|0x10000000)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|0x20000000)

    -- Add Red Rabbit and Blue Tank to hand
    Duel.CreateToken(tp,19712856)
    Duel.CreateToken(tp,19712857)

    -- Add Striker RabbitTank to Extra Deck
    local token=Duel.CreateToken(tp,19712858)
    Duel.SendtoDeck(token,nil,SEQ_DECKTOP,REASON_RULE)

    -- Register passive effect that checks every adjust phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCondition(s.passivecon)
    e2:SetOperation(s.passiveop)
    e2:SetCountLimit(1)
    Duel.RegisterEffect(e2,tp)
end

function s.rabbittankfilter(c)
    return c:IsFaceup() and c:IsCode(19712858)
end

function s.passivecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.passiveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Make all T.G. monsters Beast and Machine
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_RACE)
        e1:SetValue(RACE_BEAST)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetValue(RACE_MACHINE)
        tc:RegisterEffect(e2)
    end

    -- Add Rabbit or Tank counter (once per turn)
    if Duel.GetFlagEffect(tp,id)==0 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local tg=Duel.SelectMatchingCard(tp,s.rabbittankfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
            if tg then
                local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- "Add Rabbit"/"Add Tank"
                if opt==0 then
                    tg:AddCounter(0x111f,1) -- Rabbit Counter
                else
                    tg:AddCounter(0x1120,1) -- Tank Counter
                end
            end
        end
    end

    -- Burn if opponent has ≤2000 LP and at least 1 Rabbit and 1 Tank counter on field
    local opp_lp=Duel.GetLP(1-tp)
    if opp_lp<=2000 then
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        local rabbit=g:GetSum(Card.GetCounter,0x111f)
        local tank=g:GetSum(Card.GetCounter,0x1120)
        if rabbit>0 and tank>0 then
            if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                for tc in g:Iter() do
                    tc:RemoveCounter(tp,0x111f,tc:GetCounter(0x111f),REASON_EFFECT)
                    tc:RemoveCounter(tp,0x1120,tc:GetCounter(0x1120),REASON_EFFECT)
                end
                Duel.Damage(1-tp,opp_lp,REASON_EFFECT)
            end
        end
    end
end

function s.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x27)
end
