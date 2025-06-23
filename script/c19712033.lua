local s,id=GetID()
local WEAK_TOKEN_ID=19712035
local STRIKE_ARC=0x0801
local PUNCH_ARC=0x3801

function s.initial_effect(c)
    -- Activate this card
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- When you inflict damage with a "Punch" card, summon 1 Weak Token to opponent
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.tkcon)
    e1:SetTarget(s.tktg)
    e1:SetOperation(s.tkop)
    c:RegisterEffect(e1)

    -- Increase damage dealt by your "Strike" cards by 300 if 3+ Weak Tokens on field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1) -- Opponent takes boosted damage
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
end

-- Trigger condition: damage to opponent from your Punch card effect
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
    if ep~=1-tp then return false end
    if not re or not re:GetHandler() then return false end
    local rc=re:GetHandler()
    return rc:IsSetCard(PUNCH_ARC) and rp==tp
end

-- Target function for token summon
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
           and Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPE_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

-- Operation: summon Weak Token to opponent field
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,WEAK_TOKEN_ID,0,TYPE_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then return end
    local token=Duel.CreateToken(tp,WEAK_TOKEN_ID)
    Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
end

-- Damage value modifier: boost damage from Strike cards by 300 if 3+ Weak Tokens on field
function s.damval(e,re,val,r,rp)
    if val <= 0 then return val end
    if not re or not re:GetHandler() then return val end
    local rc = re:GetHandler()
    local tp = e:GetHandlerPlayer()
    if not rc:IsSetCard(STRIKE_ARC) then return val end
    local count = Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_MZONE, LOCATION_MZONE, nil, WEAK_TOKEN_ID)
    if count >= 3 then
        return val + 300
    end
    return val
end
