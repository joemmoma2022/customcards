local s,id=GetID()
local COUNTER_NINPO=0x1121
local FHUMA_SHURIKEN_ID=09373534
local KAGURA_ID=19712860
local CLONE_TOKEN_ID=19712863
local NINJA_HEXCODE=0x2B

function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_NINPO)

    -- Unaffected by other card effects
    local e_immune=Effect.CreateEffect(c)
    e_immune:SetType(EFFECT_TYPE_SINGLE)
    e_immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e_immune:SetRange(LOCATION_SZONE)
    e_immune:SetCode(EFFECT_IMMUNE_EFFECT)
    e_immune:SetValue(s.efilter)
    c:RegisterEffect(e_immune)

    -- Add 1 Ninpo counter during Standby Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
    e1:SetOperation(function(e,tp)
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) then
            c:AddCounter(COUNTER_NINPO,1)
        end
    end)
    c:RegisterEffect(e1)

    -- Add 2 counters when Kagura is Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(function(e,tp,eg)
        return eg:IsExists(function(c) return c:IsFaceup() and c:IsCode(KAGURA_ID) and c:IsControler(tp) end,1,nil)
    end)
    e2:SetOperation(function(e,tp)
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) then
            c:AddCounter(COUNTER_NINPO,2)
        end
    end)
    c:RegisterEffect(e2)

    -- EFFECTS UNLOCK BASED ON COUNTER THRESHOLDS (no cost to activate)

    -- 1+ counters effect: Add FHuma Shuriken to hand if control Ninja
    s.create_threshold_effect(c,1,aux.Stringid(id,1),CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,
        function(tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,NINJA_HEXCODE),tp,LOCATION_MZONE,0,1,nil) end,
        nil,
        function(e,tp)
            local token=Duel.CreateToken(tp,FHUMA_SHURIKEN_ID)
            Duel.SendtoHand(token,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,token)
        end)

    -- 3+ counters effect: Burn damage based on #Ninjas on field+grave
    s.create_threshold_effect(c,3,aux.Stringid(id,2),CATEGORY_DAMAGE,EFFECT_TYPE_IGNITION,nil,
        function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return true end
            local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,NINJA_HEXCODE)
            Duel.SetTargetPlayer(1-tp)
            Duel.SetTargetParam(ct*100)
            Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
        end,
        function(e,tp)
            local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
            Duel.Damage(p,d,REASON_EFFECT)
        end)

    -- 5+ counters effect: Destroy 1 card your field + 1 opponent card
    s.create_threshold_effect(c,5,aux.Stringid(id,3),CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,nil,
        function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then
                return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
                    and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
            end
            Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,0)
        end,
        function(e,tp)
            local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
            local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
            if #g1>0 and #g2>0 then
                g1:Merge(g2)
                Duel.Destroy(g1,REASON_EFFECT)
            end
        end)

    -- 7+ counters effect: Overlay 1 facedown card to XYZ Ninja
    s.create_threshold_effect(c,7,aux.Stringid(id,4),CATEGORY_LEAVE_GRAVE,EFFECT_TYPE_IGNITION,nil,
        function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then
                return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
                    and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(NINJA_HEXCODE) end,tp,LOCATION_MZONE,0,1,nil)
            end
        end,
        function(e,tp)
            local tc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
            local xyz=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(NINJA_HEXCODE) end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
            if tc and xyz then
                Duel.Overlay(xyz,Group.FromCards(tc))
            end
        end)

    -- 9+ counters effect: Special Summon 2 Kagura Clone tokens
    s.create_threshold_effect(c,9,aux.Stringid(id,5),CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,
        function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then
                return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,KAGURA_ID)
                    and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
                    and Duel.IsPlayerCanSpecialSummonMonster(tp,CLONE_TOKEN_ID,0,TYPES_TOKEN,2500,1250,5,RACE_WARRIOR,ATTRIBUTE_LIGHT)
            end
        end,
        function(e,tp)
            for i=1,2 do
                local token=Duel.CreateToken(tp,CLONE_TOKEN_ID)
                if token then
                    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
                end
            end
            Duel.SpecialSummonComplete()
        end)

    -- 11+ counters effect: Destroy Kagura and deal double ATK damage
    s.create_threshold_effect(c,11,aux.Stringid(id,6),CATEGORY_DESTROY+CATEGORY_DAMAGE,EFFECT_TYPE_IGNITION,nil,
        function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,KAGURA_ID) end
        end,
        function(e,tp)
            local tc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_MZONE,0,1,1,nil,KAGURA_ID):GetFirst()
            if tc and Duel.Destroy(tc,REASON_EFFECT)>0 then
                Duel.Damage(1-tp,tc:GetAttack()*2,REASON_EFFECT)
            end
        end)
end

function s.efilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end

-- New function: create effect unlocked at threshold counters (no cost)
function s.create_threshold_effect(card,threshold,desc,category,etype,cond,target,operation)
    local e=Effect.CreateEffect(card)
    e:SetDescription(desc)
    e:SetCategory(category)
    e:SetType(etype)
    e:SetRange(LOCATION_SZONE)
    e:SetCountLimit(1,id+threshold) -- Unique per effect once per turn
    e:SetCondition(function(e,tp)
        local c=e:GetHandler()
        return c:GetCounter(COUNTER_NINPO)>=threshold and (not cond or cond(tp))
    end)
    if target then e:SetTarget(target) end
    if operation then e:SetOperation(operation) end
    card:RegisterEffect(e)
end
