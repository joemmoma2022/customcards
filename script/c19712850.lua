local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon procedure: 2 Level 2 Gemini monsters
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_GEMINI),2,2)
    c:EnableReviveLimit()

    --Take control and make it a Level 8 Gemini on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.ctcon)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    --Quick Effect: Detach all materials as cost, treat self as Level 8 Gemini & Xyz Summon with another Gemini monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.xyztg)
    e2:SetOperation(s.xyzop)
    c:RegisterEffect(e2)
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc and Duel.GetControl(tc,tp) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(8)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_TYPE)
        e2:SetValue(TYPE_GEMINI)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)

        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_LEAVE_FIELD)
        e3:SetLabelObject(tc)
        e3:SetCondition(s.retcon)
        e3:SetOperation(s.retop)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        Duel.RegisterEffect(e3,tp)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetOwner())
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and Duel.GetControl(tc,1-tp) then
        Duel.RaiseSingleEvent(tc,EVENT_CONTROL_CHANGED,e,0,0,0,0)
    end
end

function s.gemfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_GEMINI)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and s.gemfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingTarget(s.gemfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.gemfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,c:GetOverlayCount(),REASON_COST) end
    c:RemoveOverlayCard(tp,c:GetOverlayCount(),c:GetOverlayCount(),REASON_COST)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end

    local mat=Group.FromCards(c,tc)

    -- Apply EFFECT_XYZ_LEVEL on materials BEFORE the summon, to treat each as Level 8
    for mc in aux.Next(mat) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_XYZ_LEVEL)
        e1:SetValue(8)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        mc:RegisterEffect(e1)
    end

    -- Also apply EFFECT_ADD_TYPE Gemini on self to ensure it's Gemini during summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetValue(TYPE_GEMINI)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local xyzs=Duel.GetMatchingGroup(function(x)
        return x:IsType(TYPE_XYZ) and x:IsXyzSummonable(nil,mat,2,2)
    end,tp,LOCATION_EXTRA,0,nil)
    if #xyzs==0 then return end

    local sc=xyzs:Select(tp,1,1,nil):GetFirst()
    if sc then
        Duel.XyzSummon(tp,sc,mat)
    end
end
