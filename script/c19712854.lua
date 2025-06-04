--Jurrac Rex Revi (cleaned version)
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,aux.FilterSummonCode(19712852),1,1)
    c:EnableReviveLimit()

    --Destroy & Burn on Synchro Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1)) -- str1
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --Quick Effect: Return to hand + revive materials (once per turn)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3)) -- str3 ("Return & Revive")
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100) -- separate once per turn
    e2:SetCondition(s.quickcon)
    e2:SetTarget(s.bouncetg)
    e2:SetOperation(s.bounceop)
    c:RegisterEffect(e2)
end

-- Synchro summon condition
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Destroy & damage target
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=#e:GetHandler():GetMaterial()
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,math.min(ct,#g),0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=#c:GetMaterial()
    local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=g:Select(tp,1,math.min(ct,#g),nil)
    local ct=Duel.Destroy(sg,REASON_EFFECT)
    local dmg=sg:Filter(Card.IsType,nil,TYPE_MONSTER):GetSum(Card.GetDefense)
    if dmg>0 then
        Duel.Damage(1-tp,dmg,REASON_EFFECT)
    end
end

-- Quick Effect condition for bounce
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,19712852)
        and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,19712853)
end

-- Bounce target & operation
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,19712852)
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,19712853)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_MZONE)
end

function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    if not c:IsRelateToEffect(e) then return end
    local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,19712852)
    local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,0,nil,19712853)
    if #g1==0 or #g2==0 then return end
    Duel.SendtoHand(c,nil,REASON_EFFECT)
    Duel.BreakEffect()
    local tc1=g1:Select(tp,1,1,nil):GetFirst()
    local tc2=g2:Select(tp,1,1,nil):GetFirst()
    if tc1 and tc2 then
        Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonComplete()
    end
end
