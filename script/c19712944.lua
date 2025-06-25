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

    -- This card is also WATER and WIND attribute
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(ATTRIBUTE_WATER+ATTRIBUTE_WIND)
    c:RegisterEffect(e1)

    -- When this card is summoned, halve an opponent monster's ATK, gain ATK and LP
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

function s.filter(c)
    return c:IsFaceup() and c:GetAttack()>0
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:GetAttack()<=0 then return end
    local atk=math.floor(tc:GetAttack()/2)
    if atk<=0 then return end

    -- Halve the target's ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)

    -- This card gains ATK equal to halved amount
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(atk)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e2)

    -- Recover LP equal to gained amount
    Duel.Recover(tp,atk,REASON_EFFECT)
end
