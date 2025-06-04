local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon procedure: 2 Level 8 Gemini monsters
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_GEMINI),8,2)
    c:EnableReviveLimit()

    --On Xyz Summon, target up to 2 opponent monsters and attach as material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.ctcon)
    e1:SetTarget(s.cttg)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    --ATK gain if this card has itself as material
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    --Once per turn, attach 1 Gemini monster from field or GY as material
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.attachtg)
    e3:SetOperation(s.attachop)
    c:RegisterEffect(e3)
end

--Check if Xyz Summoned
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

--Target up to 2 opponent monsters
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end

--Attach targeted monsters as material
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    if not c:IsRelateToEffect(e) then return end
    if #g>0 then
        for tc in aux.Next(g) do
            if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
                Duel.Overlay(c,Group.FromCards(tc))
            end
        end
    end
end

--ATK gain if "Poly-Chemicritter NitrHopper" is among materials
function s.atkval(e,c)
    local g=c:GetOverlayGroup()
    if g:IsExists(Card.IsCode,1,nil,19712850) then
        return 500*g:GetCount()
    else
        return 0
    end
end

--Filter Gemini monsters in field or GY for attaching
function s.attachfilter(c)
    return c:IsType(TYPE_GEMINI) and (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

--Target 1 Gemini monster from field or GY to attach as material
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and s.attachfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end

--Attach the targeted Gemini monster as material
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        Duel.Overlay(c,Group.FromCards(tc))
    end
end
