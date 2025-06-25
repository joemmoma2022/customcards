--Masked HERO Drageder Avenger
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    c:EnableReviveLimit()

    -- Must be Special Summoned with "Mask Change"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(function(e,se,sp,st)
        return se and se:GetHandler():IsCode(21143940) -- Mask Change
    end)
    c:RegisterEffect(e0)

    -- On Summon: Special Summon "Masked Beast - Drageder" from outside the duel
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Quick Effect: Equip 1 "Masked Beast - Drageder" to this card, gain its ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end

-- Special Summon Drageder from outside the Duel
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummon(tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local token=Duel.CreateToken(tp,19712939)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

-- Condition: Control "Masked Beast - Drageder"
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(19712939) end,tp,LOCATION_MZONE,0,1,nil)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(19712939) and c:IsControler(tp) and not c:IsImmuneToEffect(e) end,tp,LOCATION_MZONE,0,1,nil)
    end
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsCode(19712939) and c:IsControler(tp) and not c:IsImmuneToEffect(e) end,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    local c=e:GetHandler()
    if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
        if not Duel.Equip(tp,tc,c,false) then return end

        -- Equip limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return e:GetOwner()==c end)
        tc:RegisterEffect(e1)

        -- Gain ATK equal to equipped monster
        local atk=tc:GetAttack()
        if atk>0 then
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(atk)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e2)
        end
    end
end
