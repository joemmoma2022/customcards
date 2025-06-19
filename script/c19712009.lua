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

    -- Treated as all Attributes
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(ATTRIBUTE_ALL)
    c:RegisterEffect(e1)

    -- Quick Effect: Return self to ED, summon 1 Masked HERO from ED
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Filters
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xa008) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToExtraAsCost()
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            and Duel.GetLocationCountFromEx(tp,tp,c,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end

    -- Summon Masked HERO
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if not sc then return end

    if Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,true,true,POS_FACEUP)==0 then return end
    sc:CompleteProcedure()

    -- Setup End Phase return and resummon of original card (c)
    local fid=c:GetFieldID()
    sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(fid)
    e1:SetLabelObject(sc)
    e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local sc=e:GetLabelObject()
        if not sc or sc:GetFlagEffectLabel(id)~=e:GetLabel() then return end
        if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            -- Special Summon the original card from Extra Deck ignoring summoning conditions
            local og=Duel.GetMatchingGroup(function(c) return c:IsCode(id) and c:IsLocation(LOCATION_EXTRA) end,tp,LOCATION_EXTRA,0,nil)
            local oc=og:GetFirst()
            if oc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
                Duel.SpecialSummon(oc,0,tp,tp,true,true,POS_FACEUP)
            end
        end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
