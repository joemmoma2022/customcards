local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand to Special Summon 4 Gogogo Golems
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
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>3
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=3 then return end

    for i=1,4 do
        -- Create "Gogogo Golem" token (ID 62476815)
        local token=Duel.CreateToken(tp,62476815)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
            -- Set ATK and DEF to 0
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            token:RegisterEffect(e1,true)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e2:SetValue(0)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD)
            token:RegisterEffect(e2,true)

            -- Cannot be Tributed permanently
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_UNRELEASABLE_SUM)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetValue(1)
            token:RegisterEffect(e3,true)

            local e4=e3:Clone()
            e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
            token:RegisterEffect(e4,true)
        end
    end

    Duel.SpecialSummonComplete()

    -- Banish this card face-down after resolution
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
    end
end
