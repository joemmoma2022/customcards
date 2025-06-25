--Masked HERO Possessor (example name)
local s,id=GetID()
function s.initial_effect(c)
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

    -- Quick Effect: Target 1 monster your opponent controls, equip it to this card and gain its ATK
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Limit to only 1 equipped monster
    c:SetUniqueOnField(1,0,id)

    -- When this card leaves the field, destroy the equipped monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetOperation(s.leaveop)
    c:RegisterEffect(e2)
end

-- Target 1 face-up opponent's monster if there's no equip already
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
            and e:GetHandler():GetEquipGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)==0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end

-- Equip the selected monster, gain its ATK
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsFacedown() then return end

    if c:GetEquipGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)>0 then return end

    -- Equip the opponent's monster to this card
    Duel.Equip(tp,tc,c,true)

    -- Set equip limit so that the monster can only be equipped to this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return e:GetOwner()==c end)
    tc:RegisterEffect(e1)

    -- Gain ATK equal to the equipped monster's current ATK
    local atk=tc:GetAttack()
    if atk<0 then atk=0 end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(atk)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)

    -- Optional: store equipped monster's FieldID if you want to track it
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,tc:GetFieldID())
end

-- When this card leaves the field, destroy any monster it had equipped
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local eqg=c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
    if eqg:GetCount()>0 then
        Duel.Destroy(eqg,REASON_EFFECT)
    end
end
