local s,id=GetID()

-- Strike Subtypes
s.strike_sets = {
    [0x1801]=true, -- Kick
    [0x3801]=true, -- Punch
    [0x5801]=true, -- Blast
    [0x6801]=true  -- Final Attack
}

function s.initial_effect(c)
    -- Activate only if damage from a Strike card was taken
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
end

-- Activation Condition: You took effect damage from a Strike card
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    if ep~=tp or not re then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    -- Only if damage caused by opponent’s effect
    if rp~=1-tp then return false end
    -- Damage must be effect damage
    if bit.band(r,REASON_EFFECT)==0 then return false end
    -- Must be from a known Strike subtype
    if s.getStrikeSetcode(rc)==nil then return false end
    -- Must have at least one matching discardable card in hand
    return s.hasMatchingCard(tp, s.getStrikeSetcode(rc))
end

-- Target function stores damage and card handler for operation
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(ev)      -- Store damage value
    e:SetLabelObject(re) -- Store effect for later reference
end

-- Operation: Discard matching Strike card and deal damage back
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local damage = e:GetLabel()
    local re_effect = e:GetLabelObject()
    if not re_effect then return end
    local rc = re_effect:GetHandler()
    if not rc then return end

    local setcode = s.getStrikeSetcode(rc)
    if not setcode then return end

    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSetCard(setcode) and c:IsDiscardable()
    end, tp, LOCATION_HAND, 0, nil)

    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local tg=g:Select(tp,1,1,nil)
    if #tg>0 and Duel.SendtoGrave(tg,REASON_DISCARD+REASON_EFFECT)~=0 then
        Duel.Damage(1-tp,damage,REASON_EFFECT)
    end
end

-- Get the Strike subtype setcode from the card (returns one setcode or nil)
function s.getStrikeSetcode(c)
    for code,_ in pairs(s.strike_sets) do
        if c:IsSetCard(code) then
            return code
        end
    end
    return nil
end

-- Check if player has discardable card with the same Strike subtype
function s.hasMatchingCard(tp,setcode)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSetCard(setcode) and c:IsDiscardable()
    end, tp, LOCATION_HAND, 0, nil)
    return #g>0
end
