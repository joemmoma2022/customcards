local s,id=GetID()
local BLOCK_ARC=0x0772
local WEAK_TOKEN_ID=19712035

function s.initial_effect(c)
    -- Activation with unnegatable effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.blockfilter(c)
    return c:IsFaceup() and c:IsSetCard(BLOCK_ARC) and c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.blockfilter,tp,0,LOCATION_ONFIELD,1,nil)
            and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.blockfilter,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tg=g:Select(tp,1,1,nil)
    if Duel.Destroy(tg,REASON_EFFECT)==0 then return end

    Duel.Damage(1-tp,500,REASON_EFFECT)

    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then return end

    local token=Duel.CreateToken(tp,WEAK_TOKEN_ID)
    Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
end
