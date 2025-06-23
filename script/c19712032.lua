local s,id=GetID()
local WEAK_TOKEN_ID=19712035

function s.initial_effect(c)
    -- Activate: Inflict 800 damage and summon 2 Weak Tokens to opponent's field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=2
            and Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
    end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(800)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if Duel.Damage(p,d,REASON_EFFECT)==0 then return end

    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then return end

    for i=1,2 do
        local token=Duel.CreateToken(tp,WEAK_TOKEN_ID)
        Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
    end
    Duel.SpecialSummonComplete()
end
