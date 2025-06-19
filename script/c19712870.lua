local s,id=GetID()
function s.initial_effect(c)
    -- Equip only to a "Galaxy-Eyes" monster
    aux.AddEquipProcedure(c,nil,s.eqfilter)

    -- ATK boost
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1000)
    c:RegisterEffect(e1)

    -- Piercing damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)

    -- Re-equip when destroyed while face-up
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.eqcon)
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)
end

-- Equip only to "Galaxy-Eyes" monsters
function s.eqfilter(c)
    return c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER)
end

-- Re-equip condition: destroyed from field while face-up
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end

-- Re-equip target filter
function s.eqfilter2(c)
    return c:IsFaceup() and c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER)
end

-- Target for re-equip
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter2(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

-- Re-equip operation
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
        Duel.Equip(tp,c,tc)
    end
end
