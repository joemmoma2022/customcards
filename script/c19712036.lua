local s,id=GetID()
local BLEED_TOKEN_ID=19712041
local DISTRACTION_ID=19712028  -- Distraction's ID

function s.initial_effect(c)
    -- Activate: Deal damage and summon Bleed Token
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
        return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,BLEED_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local damage=400
    if Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsCode,DISTRACTION_ID),tp,LOCATION_GRAVE,0,1,nil) then
        damage=700
    end
    if Duel.Damage(1-tp,damage,REASON_EFFECT)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,BLEED_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then
        
        local token=Duel.CreateToken(tp,BLEED_TOKEN_ID)
        Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
    end
end
