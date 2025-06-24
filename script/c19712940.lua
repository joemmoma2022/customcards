--Masked HERO - Element Shifter
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Must be Special Summoned with "Masked HERO - Traveler"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(function(e,se,sp,st)
        return se and se:GetHandler():IsCode(19712009) -- Masked HERO - Traveler
    end)
    c:RegisterEffect(e0)

    -- Quick Effect: Change Attribute and apply effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetHintTiming(0,TIMING_DAMAGE_STEP|TIMING_END_PHASE)
    e1:SetTarget(s.attg)
    e1:SetOperation(s.atop)
    c:RegisterEffect(e1)
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
    return true
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
    local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
    
    -- Change attribute
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(attr)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)

    Duel.BreakEffect()

    -- Apply effect by Attribute
    if attr==ATTRIBUTE_WATER then
        -- WATER: Negate 1 attack this turn
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_ATTACK_ANNOUNCE)
        e2:SetCountLimit(1)
        e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            Duel.NegateAttack()
            e:Reset()
        end)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)

    elseif attr==ATTRIBUTE_WIND then
        -- WIND: Inflict 500 damage
        Duel.Damage(1-tp,500,REASON_EFFECT)

    elseif attr==ATTRIBUTE_EARTH then
        -- EARTH: Gain 1000 ATK
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(1000)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)

    elseif attr==ATTRIBUTE_LIGHT then
        -- LIGHT: Destroy 1 opponent monster, this card cannot attack this turn
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,1,nil)
        if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
            -- This card cannot attack this turn
            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_CANNOT_ATTACK)
            e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
            e4:SetReset(RESET_PHASE+PHASE_END)
            c:RegisterEffect(e4)
        end
    end
end
