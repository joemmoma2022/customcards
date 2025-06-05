local s,id=GetID()
local SET_NINJA=0x2b

function s.initial_effect(c)
    -- Special Summon from hand if you control a "Ninja" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Level treated as 3 or 5 Warrior-type for "Ninja" Xyz Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_XYZ_LEVEL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.xyzlv)
    c:RegisterEffect(e2)

    -- Change Race to Warrior while on field
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e3)

    -- Grant effect to Xyz monster summoned using this card as material
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.efcon)
    e4:SetOperation(s.efop)
    c:RegisterEffect(e4)

    -- This card is also treated as Machine-type everywhere
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_ADD_RACE)
    e5:SetRange(LOCATION_ALL)
    e5:SetValue(RACE_MACHINE)
    c:RegisterEffect(e5)
end

-- Special Summon condition: control a "Ninja" monster
function s.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Level treated as 3 or 5 for "Ninja" Xyz Summon
function s.xyzlv(e,c,rc)
    local lv=e:GetHandler():GetLevel()
    if rc and rc:IsSetCard(SET_NINJA) and rc:IsType(TYPE_XYZ) then
        return 5,3,lv
    else
        return lv
    end
end

-- Grant effect to Xyz monster summoned using this card as material
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_XYZ and e:GetHandler():IsLocation(LOCATION_OVERLAY)
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    if not rc or not rc:IsType(TYPE_XYZ) then return end
    if rc:GetFlagEffect(id)~=0 then return end
    rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

    -- Effect: This card cannot be destroyed by battle once per turn
    local e1=Effect.CreateEffect(rc)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.indval)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1,true)

    -- Reset the protection at the end of battle
    local e2=Effect.CreateEffect(rc)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_END)
    e2:SetOperation(function(_,tp) rc:ResetFlagEffect(id+1) end)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    Duel.RegisterEffect(e2,tp)
end

function s.indval(e,re,tp)
    local c=e:GetHandler()
    if c:GetFlagEffect(id+1)==0 then
        c:RegisterFlagEffect(id+1,RESET_PHASE+PHASE_END,0,1)
        return true
    else
        return false
    end
end
