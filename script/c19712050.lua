local s,id=GetID()
local SLASH_ARC=0x9801

function s.initial_effect(c)
    -- Activate: discard any number of "Slash" cards to inflict 500 damage each
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.slashfilter(c)
    return c:IsSetCard(SLASH_ARC) and c:IsDiscardable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.slashfilter,tp,LOCATION_HAND,0,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,#g)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.slashfilter,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    local ct=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
    if ct>0 then
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
    end
end
