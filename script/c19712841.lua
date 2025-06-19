local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x8083)
    c:EnableReviveLimit()
    --Xyz Summon
    Xyz.AddProcedure(c,nil,7,2)
    
    --Double battle damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetOperation(s.dbdop)
    c:RegisterEffect(e1)

    --Add counter when dealing battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetCondition(s.addcccon)
    e2:SetOperation(s.addccop)
    c:RegisterEffect(e2)

    --Destroy & Burn Quick Effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.descost)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    --Attack twice if Odd-Eyes Dragon is material
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_EXTRA_ATTACK)
    e4:SetCondition(s.atkcon)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

--Double battle damage
function s.dbdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if c==a or c==d then
        Duel.ChangeBattleDamage(tp,Duel.GetBattleDamage(tp)*2)
        Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)*2)
    end
end

--Add 1 Cross Counter when dealing battle damage
function s.addcccon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp
end
function s.addccop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:AddCounter(0x8083,1)
end

--Destroy & Burn Quick Effect
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetOverlayCount()>0 and e:GetHandler():IsCanRemoveCounter(tp,0x8083,2,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    e:GetHandler():RemoveCounter(tp,0x8083,2,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        Duel.Damage(1-tp,tc:GetDefense(),REASON_EFFECT)
    end
end

--Attack twice if Odd-Eyes Dragon is a material
function s.atkcon(e)
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,53025096)
end
