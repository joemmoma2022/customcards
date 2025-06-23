local s,id=GetID()
local WEAK_TOKEN_ID=19712035

function s.initial_effect(c)
    -- Activate: Inflict 700 damage and summon a Weak Token to your field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Damage(1-tp,700,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp) then return end

    local token=Duel.CreateToken(tp,WEAK_TOKEN_ID)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
