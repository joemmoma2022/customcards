--Paralyzing Cage
local s,id=GetID()
local COUNTER_ID=0x8390
function s.initial_effect(c)
    --Allow counters
    c:EnableCounterPermit(COUNTER_ID)

    --Activate: add 3 counters and apply effects to current monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --Banish if this card leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e2)

    --Negate effects, cannot attack, cannot change battle position for monsters affected
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.monsterfilter)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e4)

    local e5=e3:Clone()
    e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    c:RegisterEffect(e5)

    --Remove 1 counter during each opponent End Phase; destroy if none left
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetCountLimit(1)
    e6:SetCondition(s.ctcon)
    e6:SetOperation(s.ctop)
    c:RegisterEffect(e6)
end

--Target: all face-up monsters on field
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0)
end

--Activate: add 3 counters and hint selection
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    c:AddCounter(COUNTER_ID,3)
    --Hint selection for all current monsters
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g>0 then
        for tc in aux.Next(g) do
            Duel.HintSelection(Group.FromCards(tc))
        end
    end
end

--Filter for monsters affected by this card
function s.monsterfilter(e,c)
    local tcg=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
    return tcg:IsContains(c)
end

--Opponent End Phase counter removal
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(COUNTER_ID)>0 then
        c:RemoveCounter(tp,COUNTER_ID,1,REASON_EFFECT)
    else
        if c:IsRelateToEffect(e) then
            Duel.Destroy(c,REASON_EFFECT)
        end
    end
end
