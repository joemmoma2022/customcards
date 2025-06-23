local s,id=GetID()

function s.initial_effect(c)
    -- Activate: inflict 100 damage, then draw 1 and discard 1
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Damage(1-tp,100,REASON_EFFECT)>0 then
        if Duel.Draw(tp,1,REASON_EFFECT)==1 then
            Duel.ShuffleHand(tp)
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end
