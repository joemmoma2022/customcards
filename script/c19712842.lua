local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Xyz Summon Procedure
    Xyz.AddProcedure(c,nil,5,3)
    --Alternative Xyz Summon using Malevolent Sin
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.xyzcon)
    e1:SetOperation(s.xyzop)
    e1:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e1)
    --Banish Target
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
    --Attack gain & Rank up after attacking
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    --Malevolent Sin effect (Quick Effect banish if battles opponent's monster)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.malecon)
    e4:SetOperation(s.maleop)
    c:RegisterEffect(e4)
end
s.listed_names={80796456} -- Number 70: Malevolent Sin

--Alternative Summon Condition
function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local sc=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):Filter(Card.IsCode,nil,80796456)
    return #sc>0 and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local tc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_MZONE,0,1,1,nil,80796456):GetFirst()
    local mg=tc:GetOverlayGroup()
    if #mg>0 then
        Duel.Overlay(c,mg)
    end
    Duel.Overlay(c,tc)
    c:SetMaterial(Group.FromCards(tc))
end

--Banish effect cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
--Banish effect target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
--Banish effect operation
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
            e1:SetLabelObject(tc)
            e1:SetCountLimit(1)
            e1:SetCondition(s.retcon)
            e1:SetOperation(s.retop)
            e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(1-tp) and e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ReturnToField(e:GetLabelObject())
end

--Attack gain & Rank up after attacking (Malevolent Sin style)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattledGroupCount()>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        -- Increase ATK by 500
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
        -- Increase Rank by 5
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_RANK)
        e2:SetValue(5)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e2)
    end
end

--Malevolent Sin Quick Effect to banish battle opponent's monster until opponent's next Standby Phase
function s.malecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=Duel.GetAttackTarget()
    return bc and bc:IsControler(1-tp) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,80796456)
        and Duel.GetAttacker()==c
end
function s.maleop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=Duel.GetAttackTarget()
    if bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
        if Duel.Remove(bc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            bc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
            e1:SetLabelObject(bc)
            e1:SetCountLimit(1)
            e1:SetCondition(s.retcon)
            e1:SetOperation(s.retop)
            e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
