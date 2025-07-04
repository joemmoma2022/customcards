--Custom Fusion Parasite Clone
local s,id=GetID()
local FUSION_PARASITE_ID=6205579

function s.initial_effect(c)
    -- Treated as "Fusion Parasite" in hand, field, S/T zone, or GY
    for _,zone in ipairs({LOCATION_HAND,LOCATION_MZONE,LOCATION_SZONE,LOCATION_GRAVE}) do
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e0:SetRange(zone)
        e0:SetCode(EFFECT_CHANGE_CODE)
        e0:SetValue(FUSION_PARASITE_ID)
        c:RegisterEffect(e0)
    end

    -- Can substitute for any 1 Fusion Material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e1:SetCondition(s.subcon)
    c:RegisterEffect(e1)

    -- On Special Summon: equip 1 "Fusion Parasite" from Deck, GY, or hand to a monster, reduce ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end

-- Fusion substitute condition: must be face-up
function s.subcon(e)
    return e:GetHandler():IsFaceup()
end

-- Equip filter for Fusion Parasite
function s.eqfilter(c)
    return c:IsCode(FUSION_PARASITE_ID) and not c:IsForbidden()
end

-- Targeting a monster
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

-- Equip and apply code-change + ATK reduction
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
    local ec=g:GetFirst()
    if not ec then return end

    -- Move to field face-up first to prevent it from being FD
    if Duel.MoveToField(ec,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        Duel.Equip(tp,ec,tc,false)

        -- Equip limit
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==tc end)
        ec:RegisterEffect(e1)

        -- Change its code to Fusion Parasite in all zones
        for _,zone in ipairs({LOCATION_HAND,LOCATION_MZONE,LOCATION_SZONE,LOCATION_GRAVE}) do
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(zone)
            e2:SetCode(EFFECT_CHANGE_CODE)
            e2:SetValue(FUSION_PARASITE_ID)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            ec:RegisterEffect(e2)
        end

        -- ATK reduction: count Fusion Parasites on field
        local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,FUSION_PARASITE_ID)
        if ct>0 then
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_UPDATE_ATTACK)
            e3:SetValue(-ct*100)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e3)
        end
    end
end
