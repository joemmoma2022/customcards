local s,id=GetID()

function s.initial_effect(c)
    -- Inflict 400 damage, then if successful inflict 300 more damage
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(400)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local dmg1=400
    local dmg2=300
    if Duel.Damage(p,dmg1,REASON_EFFECT)~=0 then
        Duel.Damage(p,dmg2,REASON_EFFECT)
    end
end
