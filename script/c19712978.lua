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

    -- Fusion substitute while face-up on field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e1:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
    c:RegisterEffect(e1)

    -- On Special Summon: target opponent's GY monster, make it Fusion Parasite, equip it, take control
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end

-- Filter for valid opponent's GY monster
function s.eqfilter(c,tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget() and c:IsAbleToChangeControler()
end

-- Targeting opponent's GY monster
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_GRAVE,1,nil,tp)
            and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

-- Equip and gain control
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    local gyc=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
    local tc=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
    if not gyc or not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if Duel.Equip(tp,gyc,tc,false)==0 then return end

    -- Equip limit
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return c==tc end)
    gyc:RegisterEffect(e1)

        -- Change its code to Fusion Parasite while on field, in S/T zone, or in GY
    local zones={LOCATION_HAND,LOCATION_MZONE,LOCATION_SZONE,LOCATION_GRAVE}
    for _,zone in ipairs(zones) do
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetRange(zone)
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(FUSION_PARASITE_ID)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        gyc:RegisterEffect(e2)
    end

    -- Take control of the monster it's equipped to
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp)
    end
end
