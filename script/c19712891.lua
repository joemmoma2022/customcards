local s,id=GetID()
function s.initial_effect(c)
    -- Activate on attack declaration while you control a Winged Beast
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Condition: You control a Winged Beast, and opponent is attacking
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_WINGEDBEAST)
        and a:IsControler(1-tp)
end

-- Target: the attacking monster
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Operation: reduce ATK by Level × 200 until end of turn
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    if not a:IsRelateToBattle() or not a:IsFaceup() or a:IsImmuneToEffect(e) then return end
    local lv=a:GetLevel()
    if lv<=0 then return end
    local atk_down=lv*200

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-atk_down)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    a:RegisterEffect(e1)
end
