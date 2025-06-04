local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Xyz Summon procedure
    Xyz.AddProcedure(c,nil,5,2)
    
    --Alternative Xyz Summon using a "Ninja" Xyz monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.xyzcon)
    e1:SetOperation(s.xyzop)
    e1:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e1)

    --Quick Effect: Set 1 "Ninjitsu Art" S/T or Special Summon 1 "Ninja" monster face-down
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.setsptg)
    e2:SetOperation(s.setspop)
    c:RegisterEffect(e2)

    --Direct attack condition
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    e3:SetCondition(s.dircon)
    c:RegisterEffect(e3)

    --Burn damage trigger effect after dealing direct battle damage
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetCondition(s.damcon)
    e4:SetTarget(s.damtg)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_NINJA,SET_NINJITSU_ART}

-- Alternative Xyz Summon condition and operation --
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_NINJA) and c:IsType(TYPE_XYZ)
end
function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    local mg=tc:GetOverlayGroup()
    if #mg>0 then
        Duel.Overlay(c,mg)
    end
    Duel.Overlay(c,tc)
    c:SetMaterial(Group.FromCards(tc))
end

-- Cost: detach 1 material
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Filters for Set and Special Summon options
function s.setfilter(c)
    return c:IsSetCard(SET_NINJITSU_ART) and c:IsSpellTrap() and c:IsSSetable()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NINJA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

-- Check if attached Ninja Xyz material exists (for GY inclusion)
function s.has_ninja_xyzmat(c)
    local mg=c:GetOverlayGroup()
    return mg:IsExists(function(mc) return mc:IsSetCard(SET_NINJA) and mc:IsType(TYPE_XYZ) end,1,nil)
end

-- Target for Quick Effect: either Set or Special Summon
function s.setsptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local includeGY = s.has_ninja_xyzmat(c)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
            (Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
            or Duel.IsExistingMatchingCard(function(c) return s.spfilter(c,e,tp) and (c:IsLocation(LOCATION_DECK+LOCATION_HAND) or (includeGY and c:IsLocation(LOCATION_GRAVE))) end,tp,LOCATION_DECK+LOCATION_HAND+(includeGY and LOCATION_GRAVE or 0),0,1,nil))
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+(includeGY and LOCATION_GRAVE or 0))
end

-- Operation: choose and either Set or Special Summon FD
function s.setspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local includeGY = s.has_ninja_xyzmat(c)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local canSet = Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
    local canSp = Duel.IsExistingMatchingCard(function(c) return s.spfilter(c,e,tp) and (c:IsLocation(LOCATION_DECK+LOCATION_HAND) or (includeGY and c:IsLocation(LOCATION_GRAVE))) end,tp,LOCATION_DECK+LOCATION_HAND+(includeGY and LOCATION_GRAVE or 0),0,1,nil)
    if not (canSet or canSp) then return end

    local opt=0
    if canSet and canSp then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0=Set S/T, 1=Special Summon
    elseif canSet then
        opt=0
    else
        opt=1
    end

    if opt==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,function(c) return s.spfilter(c,e,tp) and (c:IsLocation(LOCATION_DECK+LOCATION_HAND) or (includeGY and c:IsLocation(LOCATION_GRAVE))) end,tp,LOCATION_DECK+LOCATION_HAND+(includeGY and LOCATION_GRAVE or 0),0,1,1,nil)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- Direct attack condition
function s.dircon(e)
    return s.has_ninja_xyzmat(e:GetHandler())
end

-- Burn damage trigger condition: after dealing direct battle damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return ep~=tp and c:GetBattleTarget()==nil and s.has_ninja_xyzmat(c)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=e:GetHandler():GetOverlayCount()
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(ct*200)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
