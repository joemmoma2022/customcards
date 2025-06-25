--Masked HERO - Type Breaker (example name)
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Must be Special Summoned with "Masked HERO - Traveler"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
 e0:SetValue(function(e,se,sp,st)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_EXTRA) and se and se:GetHandler():IsCode(19712009)
end)
    c:RegisterEffect(e0)

    -- Quick Effect: Discard 1 card, apply effect based on discarded card type
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Cost: Discard 1 card and store its type
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        e:SetLabel(tc:GetOriginalType() & 0x7) -- Store basic type: 1=Monster, 2=Spell, 4=Trap
        Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local t=e:GetLabel()
    if chk==0 then
        if t==TYPE_MONSTER then
            return true
        elseif t==TYPE_TRAP then
            return true
        elseif t==TYPE_SPELL then
            return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
        end
        return false
    end
    if t==TYPE_SPELL then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
        Duel.SetTargetCard(g)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local t=e:GetLabel()
    if t==TYPE_MONSTER then
        -- This card can attack twice this turn
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    elseif t==TYPE_TRAP then
        -- This card cannot be destroyed by card effects this turn
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    elseif t==TYPE_SPELL then
        -- Destroy 1 card your opponent controls
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            Duel.Destroy(tc,REASON_EFFECT)
        end
    end
end
