local s,id=GetID()
local CARD_UMI=22702055
local BIG_UMI=19712909
local DOLPHIN_KING=19712903

function s.initial_effect(c)
	-- Special Summon from hand if "Umi" or "Big Umi" is on the field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	-- Once per turn: Tribute this card, Special Summon 1 "Dolphin King Iruqua" from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

-- Special Summon condition: "Umi" or "Big Umi" on field
function s.umifilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_UMI) or c:IsCode(BIG_UMI))
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.umifilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end

-- Cost: Tribute this card
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- Filter for "Dolphin King Iruqua" in hand or grave
function s.spfilter(c,e,tp)
	return c:IsCode(DOLPHIN_KING) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target for special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
