--Darklord Xyz Monster
local s,id=GetID()
local SANCTUARY_ID=19712868 -- Desecrated Sanctuary card code

function s.initial_effect(c)
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,s.matfilter,11,2)

    -- Alternate Xyz Summon using 1 "Darklord" Fusion or Link monster
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.altcon)
    e0:SetOperation(s.altop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    -- This card is also a Fairy
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetValue(RACE_FAIRY)
    c:RegisterEffect(e1)

    -- Quick Effect: Apply a "Darklord" Spell/Trap effect if controller has Sanctuary
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.sanctuarycon)
    e2:SetTarget(s.dltg)
    e2:SetOperation(s.dlop)
    c:RegisterEffect(e2)

    -- Can attack twice after battle destruction
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCountLimit(1)
    e3:SetCondition(s.dblcon)
    e3:SetTarget(s.dbltg)
    e3:SetOperation(s.dblop)
    c:RegisterEffect(e3)

    -- Reduce opponent ATK/DEF by this card's ATK
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)

    -- Protect controller's Sanctuary on field from effects
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTargetRange(LOCATION_ONFIELD,0)
    e6:SetTarget(s.protg)
    e6:SetValue(1)
    e6:SetCondition(s.sanctuarycon)
    e6:SetCountLimit(1)
    c:RegisterEffect(e6)

    -- Destroy self if controller's Sanctuary leaves the field
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_LEAVE_FIELD)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.sdescon)
    e7:SetOperation(s.sdesop)
    c:RegisterEffect(e7)
end

function s.matfilter(c)
    return c:IsSetCard(0xef)
end

-- Alternate Xyz Summon
function s.altcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.CheckReleaseGroup(tp,s.altfilter,1,nil,tp)
end

function s.altfilter(c,tp)
    return c:IsSetCard(0xef) and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_LINK)) and c:IsControler(tp)
end

function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.altfilter,1,1,nil,tp)
    Duel.Release(g,REASON_COST)
end

-- Quick Effect condition: controller must have Sanctuary face-up on field
function s.sanctuarycon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local controller=c:GetControler()
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,SANCTUARY_ID), controller, LOCATION_ONFIELD, 0, 1, nil)
end

-- Filter for Darklord Spell/Trap in grave that can activate effect
function s.dlfilter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:CheckActivateEffect(false,true,false)~=nil
end

function s.dltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.dlfilter,tp,LOCATION_GRAVE,0,1,nil) end
end

function s.dlop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local g=Duel.SelectMatchingCard(tp,s.dlfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    local te=tc:CheckActivateEffect(false,true,true)
    if te then
        local op=te:GetOperation()
        if op then op(e,tp,eg,ep,ev,re,r,rp) end
    end
end

-- Condition for double attack after battle destroying
function s.dblcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsRelateToBattle()
end

function s.dbltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
end

function s.dblop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- Reduce opponent monsters' ATK/DEF by this card's ATK
function s.atkval(e,c)
    return -e:GetHandler():GetAttack()
end

-- Target for protection: only the controller's Sanctuary card
function s.protg(e,c)
    local controller=e:GetHandler():GetControler()
    return c:IsFaceup() and c:IsCode(SANCTUARY_ID) and c:IsControler(controller)
end

-- Condition: if the controller's Sanctuary leaves the field
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local controller=c:GetControler()
    return eg:IsExists(function(card)
        return card:IsPreviousControler(controller)
            and card:IsCode(SANCTUARY_ID)
            and card:IsPreviousLocation(LOCATION_ONFIELD)
            and card:IsPreviousPosition(POS_FACEUP)
    end,1,nil)
end

function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
