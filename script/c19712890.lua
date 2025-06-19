local s,id=GetID()
function s.initial_effect(c)
    -- Activate on opponent's summon while you control a Winged Beast
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

-- You must control a Winged Beast monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return tp~=ep and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_WINGEDBEAST)
end

-- Target summoned monsters that can be turned to Defense
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(Card.IsCanChangePosition,1,nil) end
    Duel.SetTargetCard(eg)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

-- Change to Defense, burn 500, and lock position until End Phase
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    local changed=false
    for tc in g:Iter() do
        if tc:IsFaceup() and tc:IsCanChangePosition() then
            if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
                changed=true

                -- Cannot change battle position until End Phase
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
                e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
            end
        end
    end
    if changed then
        Duel.Damage(1-tp,500,REASON_EFFECT)
    end
end
