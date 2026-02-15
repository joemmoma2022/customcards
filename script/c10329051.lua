--Healing Spore Summon
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand to Special Summon up to 4 Healing Spore monsters
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

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then return ft>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,math.min(4,ft),tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local num=math.min(4,ft)
    for i=1,num do
        -- Special Summon "Healing Spore" monster (ID 103290410)
        local token=Duel.CreateToken(tp,103290410)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
            -- Cannot be tributed this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UNRELEASABLE_SUM)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD+RESET_PHASE+PHASE_END)
            token:RegisterEffect(e1,true)

            local e2=e1:Clone()
            e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
            token:RegisterEffect(e2,true)
        end
    end
    Duel.SpecialSummonComplete()

    -- Banish this card face-down after resolution
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
