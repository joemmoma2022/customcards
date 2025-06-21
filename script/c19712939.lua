--Equip-Beetle Armor
local s,id=GetID()
function s.initial_effect(c)
    -- Union procedure
    aux.AddUnionProcedure(c,nil,true)
    c:EnableReviveLimit()

    -- ATK boost during Damage Step only while equipped by its own effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetCondition(aux.IsUnionState)
    e1:SetValue(s.damval)
    c:RegisterEffect(e1)

    -- Banish face-down when destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetOperation(s.banishfd)
    c:RegisterEffect(e2)
end

-- Only boost during Damage Step
function s.damval(e,c)
    local ph=Duel.GetCurrentPhase()
    if ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL then
        return 3000
    else
        return 0
    end
end

-- Banish face-down operation
function s.banishfd(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
