local s,id=GetID()
local BLOCK_ARC=0x0772

function s.initial_effect(c)
    -- This card cannot be negated by "Block" cards
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_INACTIVATE)
    e0:SetValue(s.efilter)
    c:RegisterEffect(e0)
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e0b:SetValue(s.efilter)
    c:RegisterEffect(e0b)

    -- Inflict 500 damage and destroy all opponent's "Block" cards
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.efilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    if not te then return false end
    local rc=te:GetHandler()
    return rc and rc:IsSetCard(BLOCK_ARC)
end

function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(BLOCK_ARC)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
    if #g>0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    if Duel.Damage(p,500,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
