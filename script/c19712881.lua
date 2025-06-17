-- Insect Assistant
-- Card ID placeholder: 19720001 (change as needed)
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if you control an Insect monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Grant effect to Insect Xyz monster if used as material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end

-- Special Summon Condition: You control an Insect monster
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Grant effect if used as material for Insect Xyz
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsRace(RACE_INSECT)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if not rc then return end
	-- Gain LP on Xyz Summon based on Rank
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end

function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rk=e:GetHandler():GetRank()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rk*400)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local rk=e:GetHandler():GetRank()
	if rk>0 then
		Duel.Recover(tp,rk*400,REASON_EFFECT)
	end
end
