--Custom Galaxy-Eyes Xyz
local s,id=GetID()
function s.initial_effect(c)
    --Standard Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x7b),8,2)
    c:EnableReviveLimit()

    --Alternative Xyz Summon using Galaxy-Eyes Photon Dragon with Meteorstrike
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    --Quick Effect: Once per turn, Battle Step banish both monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMING_BATTLE_STEP)
    e1:SetCountLimit(1)
    e1:SetCondition(s.bancon)
    e1:SetTarget(s.bantg)
    e1:SetOperation(s.banop)
    c:RegisterEffect(e1)
end

--Alternative Xyz Summon filter: Galaxy-Eyes Photon Dragon with Meteorstrike
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsCode(93717133) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,19712870)
end
function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local mg=tc:GetOverlayGroup()
        if #mg>0 then
            Duel.SendtoGrave(mg,REASON_RULE)
        end
        c:SetMaterial(Group.FromCards(tc))
        Duel.Overlay(c,Group.FromCards(tc))
    end
end

--Banish Battle Effect
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase() and e:GetHandler():GetBattleTarget()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if chk==0 then return bc and bc:IsOnField() and c:IsAbleToRemove() and bc:IsAbleToRemove() end
    Duel.SetTargetCard(bc)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,Group.FromCards(bc,c),2,0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end

    -- Check if card is equipped with Galaxy Meteorstrike
    local skipBanish=false
    if c:GetEquipGroup():IsExists(Card.IsCode,1,nil,19712870) then
        skipBanish=true
    end

    -- Remove opponent’s monster first
    if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        tc:RegisterFlagEffect(id,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        local g=Group.CreateGroup()
        g:AddCard(tc)

        -- Only remove this card if not skipping banish
        if not skipBanish and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            c:RegisterFlagEffect(id,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
            g:AddCard(c)
        end

        g:KeepAlive()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(g)
        e1:SetOperation(s.ret_op)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.retfilter(c)
    return c:GetFlagEffect(id)~=0
end
function s.ret_op(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local sg=g:Filter(s.retfilter,nil)
    for tc in aux.Next(sg) do
        Duel.ReturnToField(tc)
    end
    g:DeleteGroup()
end
