--Custom Gem-Archetype Monster
local s,id=GetID()
function s.initial_effect(c)
    -- Also treated as Rock and Insect
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_RACE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(RACE_ROCK+RACE_INSECT)
    c:RegisterEffect(e0)

    -- Cannot be Special Summoned from the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)

    -- On Special Summon: destroy opponent's monsters and gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Cannot be Special Summoned from the GY
function s.splimit(e,se,sp,st)
    return not (st & SUMMON_TYPE_SPECIAL == SUMMON_TYPE_SPECIAL and e:GetHandler():IsLocation(LOCATION_GRAVE))
end

-- Count "Gem-" and "Gem-Knight" monsters
function s.gemfilter(c)
    return c:IsMonster() and (c:IsSetCard(0x47) or c:IsSetCard(0x1047))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(s.gemfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    local ct=Duel.Destroy(tg,REASON_EFFECT)
    if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*1500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
