-- Parasite Queen
local s,id=GetID()
local FUSION_PARASITE_ID=6205579
local PARASITE_QUEEN_ID=511009344    
local PARASITE_PRINCESS_ID=19712980 

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Materials: "Fusion Parasite" + 1 Insect monster
    Fusion.AddProcMix(c,true,true,FUSION_PARASITE_ID,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT))

    -- Unaffected by effects of "Parasite Queen"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_IMMUNE_EFFECT)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(s.efilter)
    c:RegisterEffect(e0)

    -- Gains 100 ATK per "Fusion Parasite" on the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- All other monsters lose 300 ATK per "Fusion Parasite" on field (except Queen & Princess)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.debufffilter)
    e2:SetValue(s.debuffval)
    c:RegisterEffect(e2)

    -- When opponent's monster declares an attack: equip 1 Fusion Parasite and take control
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.eqcon)
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)

    -- Special Summon self from GY if Parasite Queen is Special Summoned
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- Unaffected by effects of Parasite Queen
function s.efilter(e,re)
    local rc=re:GetHandler()
    return rc and rc:IsCode(PARASITE_QUEEN_ID)
end

-- ATK gain per Fusion Parasite on field
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,FUSION_PARASITE_ID)*100
end

-- ATK debuff filter (exclude Parasite Queen & Parasite Princess)
function s.debufffilter(e,c)
    return not c:IsCode(PARASITE_QUEEN_ID) and not c:IsCode(PARASITE_PRINCESS_ID)
end

-- ATK debuff value
function s.debuffval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,FUSION_PARASITE_ID)*-300
end

-- Condition: Opponent declares an attack
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    return tc and tc:IsControler(1-tp) and tc:IsFaceup()
end

-- Target for equip effect
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        return ft>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,Duel.GetAttacker(),1,0,0)
end

-- Filter for equip: Fusion Parasite cards
function s.eqfilter(c)
    return c:IsCode(FUSION_PARASITE_ID) and not c:IsForbidden()
end

-- Equip and take control operation
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    if not (tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) and tc:IsFaceup()) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local ec=g:GetFirst()
    if not ec then return end
    if Duel.Equip(tp,ec,tc) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==tc end)
        ec:RegisterEffect(e1)
        Duel.GetControl(tc,tp)
    end
end

-- Condition: Parasite Queen is Special Summoned to your field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsFaceup() and c:IsCode(PARASITE_QUEEN_ID) and c:IsControler(tp) end,1,nil)
end

-- Target for special summoning self from GY and equip
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        local ft2=Duel.GetLocationCount(tp,LOCATION_SZONE)
        return ft>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            and ft2>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end

-- Special Summon self and equip 1 Fusion Parasite from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        if ft<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        local ec=g:GetFirst()
        if ec then
            Duel.Equip(tp,ec,c)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(function(e,c) return c==c end)
            ec:RegisterEffect(e1)
        end
    end
end
