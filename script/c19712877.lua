-- Melodious Hyperstardust Divina
local s,id=GetID()

function s.initial_effect(c)
    -- Link Summon: 4 Fairy monsters
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),4,4)

    -- On Link Summon: summon 3 Tokens if a "Melodious Maestra" monster was used
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.sumcon)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)

    -- Battle protection if pointing to a monster with a Rockin' counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetCondition(s.protcon)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)

    -- Once per turn: remove 1 Rockin' counter, destroy 1 opponent's card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- Check if Link Summon used a Melodious Maestra monster
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_LINK) then return false end
    local mg=c:GetMaterial()
    return mg:IsExists(function(mc) return mc:IsSetCard(0x109b) end,1,nil)
end

-- Token summon target check
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>2
            and Duel.IsPlayerCanSpecialSummonMonster(tp,19712879,0,TYPES_TOKEN,0,0,8,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end

-- Token summon operation
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,19712879,0,TYPES_TOKEN,0,0,8,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP,tp) then return end

    for i=1,3 do
        local token=Duel.CreateToken(tp,19712879)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)

        -- Add 1 Rockin' Counter
        token:AddCounter(0x1320,1)

        -- Cannot be tributed or used as material
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UNRELEASABLE_SUM)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
        token:RegisterEffect(e2)
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
        e3:SetValue(1)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e3)
    end
    Duel.SpecialSummonComplete()
end

-- Battle protection: must be pointing to a monster with a Rockin' counter
function s.protcon(e)
    local c=e:GetHandler()
    local tp=c:GetControler()
    local zone=c:GetLinkedZone(tp)
    for i=0,4 do
        local seq=s.ZoneToSequence(zone,i)
        if seq then
            local mc=Duel.GetFieldCard(tp,LOCATION_MZONE,seq)
            if mc and mc:IsFaceup() and mc:GetCounter(0x1320)>0 then
                return true
            end
        end
    end
    return false
end

function s.ZoneToSequence(zone,check)
    for i=0,4 do
        if (zone & (1 << i)) ~= 0 then
            if check==0 then return i end
            check=check-1
        end
    end
    return nil
end

-- Destroy effect condition: can remove 1 Rockin' counter
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsCanRemoveCounter(tp,1,0,0x1320,1,REASON_COST)
end

-- Target an opponent's card to destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.RemoveCounter(tp,1,0,0x1320,1,REASON_COST)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

-- Destroy operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
