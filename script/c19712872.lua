--Speedroid Synchro Surge
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon Hi-Speedroid Warrior Tridoron
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Must control a face-up Speedroid monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x2016) end, tp, LOCATION_MZONE, 0, 1, nil)
end

-- Filter to find valid face-up Speedroid monster
function s.matfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER)
end

-- Filter for valid materials from hand or deck
function s.extra_matfilter(c)
    return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

-- Check for Hi-Speedroid Warrior Tridoron
function s.tridoronfilter(c,e,tp)
    return c:IsCode(19712871) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.extra_matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
            and Duel.GetLocationCountFromEx(tp,tp,nil,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.tridoronfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Send this Spell card to the Graveyard first
    if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end

    -- Pick a face-up Speedroid on field as required material
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not tc then return end

    local tridoron=Duel.GetFirstMatchingCard(s.tridoronfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if not tridoron then return end

    local mg=Duel.GetMatchingGroup(s.extra_matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    mg:AddCard(tc)

    local lv=tridoron:GetLevel()

    -- Ensure tuner is present and total level matches
    local function reschk(g,tp)
        return g:CheckWithSumEqual(Card.GetLevel,lv,#g,#g) and g:IsExists(Card.IsType,1,nil,TYPE_TUNER)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,reschk,1,tp,HINTMSG_TOGRAVE,reschk)
    if not mat or #mat==0 then return end

    if Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_SYNCHRO)==#mat then
        Duel.BreakEffect()
        Duel.SpecialSummon(tridoron,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
        tridoron:CompleteProcedure()
    end
end
