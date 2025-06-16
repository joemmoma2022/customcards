-- Rockin' Boombox Token
-- Scripted by You
local s,id=GetID()

function s.initial_effect(c)
    -- Cannot be Tributed for a Tribute Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Cannot be Tributed for non-Summon purposes
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e2)

    -- Cannot be used as material for Fusion/Synchro/XYZ/Link
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end
