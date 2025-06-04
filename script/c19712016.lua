--Taunt (Quick-Play Spell)
local s,id=GetID()

local STRIKE_SETCODE=0x0801  -- Strike archetype
local BLOCK_SETCODE=0x772    -- Block archetype

function s.initial_effect(c)
    -- Activate from hand (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Activate from set (face-down) on the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)

    -- Allow activation the turn this card is set (Quick-Play Spell)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e3)
end

function s.blockfilter(c)
    return c:IsSetCard(BLOCK_SETCODE) and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.blockfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
    if chk==0 then return #g>0 end
    Duel.SendtoGrave(g,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Restrict opponent's activations to only Strike cards during YOUR turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1) -- Opponent only
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
    Duel.RegisterEffect(e1,tp)

    -- Restrict opponent's setting to only Strike cards during YOUR turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SSET)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1) -- Opponent only
    e2:SetTarget(s.setlimit)
    e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
    Duel.RegisterEffect(e2,tp)

    -- Send this card to Graveyard after activation
    if c:IsRelateToEffect(e) then
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end

-- Activation limit: deny activation of non-Strike cards
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    if not rc then return false end
    return not rc:IsSetCard(STRIKE_SETCODE)
end

-- Setting limit: deny setting of non-Strike cards
function s.setlimit(e,c)
    if not c then return false end
    return not c:IsSetCard(STRIKE_SETCODE)
end
