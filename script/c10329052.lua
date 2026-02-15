--Gigantic Healing Spore
local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand to Special Summon 1 "Gigantic Healing Spore"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1) 
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Targeting
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,103290411,0,0x4011,0,0,1,RACE_PLANT,ATTRIBUTE_WIND) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,103290411,0,0x4011,0,0,1,RACE_PLANT,ATTRIBUTE_WIND) then return end

    local token=Duel.CreateToken(tp,103290411)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)

    -- Banish this card face-down after resolution
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
