local s,id=GetID()
local SLASH_ARC=0x9801
local BLEED_TOKEN_ID=19712041

function s.initial_effect(c)
    -- Activate: Discard all Slash cards, inflict damage, summon tokens
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter_slash(c)
    return c:IsSetCard(SLASH_ARC) and c:IsDiscardable(REASON_EFFECT)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter_slash,tp,LOCATION_HAND,0,1,nil)
        and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,0,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,1-tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.filter_slash,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    local ct=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
    if ct==0 then return end
    local dam=700*ct
    Duel.Damage(1-tp,dam,REASON_EFFECT)
    local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
    if ft==0 then return end
    local token_ct=math.min(ct,ft)
    for i=1,token_ct do
        local token=Duel.CreateToken(tp,BLEED_TOKEN_ID)
        Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
    end
    Duel.SpecialSummonComplete()
end
