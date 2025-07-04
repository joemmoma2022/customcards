--Custom Fusion Parasite Clone v3
local s,id=GetID()
local FUSION_PARASITE_ID=6205579

function s.initial_effect(c)
    -- Treated as "Fusion Parasite" in hand, field, Spell/Trap zone, or GY
    for _,zone in ipairs({LOCATION_HAND,LOCATION_MZONE,LOCATION_SZONE,LOCATION_GRAVE}) do
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e0:SetRange(zone)
        e0:SetCode(EFFECT_CHANGE_CODE)
        e0:SetValue(FUSION_PARASITE_ID)
        c:RegisterEffect(e0)
    end

    -- Can substitute for 1 Fusion Material while face-up
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e1:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
    c:RegisterEffect(e1)

    -- Special Summon itself if you control no monsters (Built-in procedure)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    e2:SetValue(SUMMON_TYPE_SPECIAL+0x1)
    c:RegisterEffect(e2)

    -- If Special Summoned by this effect: summon another Fusion Parasite
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.sscon)
    e3:SetTarget(s.sstg)
    e3:SetOperation(s.ssop)
    c:RegisterEffect(e3)
end

-- Special Summon condition: no monsters
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- Special Summon operation: register flag before summon completes
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
end

-- Trigger condition: only if summoned by our special summon proc
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end

-- Filter for Fusion Parasite in hand or GY
function s.ssfilter(c,e,tp)
    return c:IsCode(FUSION_PARASITE_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target for second Fusion Parasite summon
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- Operation for second Fusion Parasite summon
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
