local s,id=GetID()

local CROSS_COUNTER=0x8083
local CROSS_Z_ID=19712841
local ODD_EYES_SET=0x99

function s.initial_effect(c)
	-- Effect 1: Activate on Odd-Eyes Dragon destroyed, Special Summon Cross Z and attach Odd-Eyes from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)  -- effect 1 limit
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Effect 2: From GY, banish to place Cross Counter on Cross Z monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)  -- different limit ID so effect 2 doesn't block effect 1
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
end

-- Filter: Odd-Eyes Dragon destroyed you controlled by battle or effect
function s.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsSetCard(ODD_EYES_SET) and c:IsType(TYPE_MONSTER)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end

-- Target for special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCountFromEx(tp)>0
			and Duel.IsExistingMatchingCard(function(c) return c:IsCode(CROSS_Z_ID) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false) end,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(ODD_EYES_SET) and c:IsMonster() end,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Operation: Special Summon Cross Z ignoring summoning conditions + attach Odd-Eyes from GY as material
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local xyzg=Duel.GetMatchingGroup(function(c) return c:IsCode(CROSS_Z_ID) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false) end,tp,LOCATION_EXTRA,0,nil)
	if #xyzg==0 then return end
	local xyz=xyzg:GetFirst()
	if Duel.SpecialSummonStep(xyz,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP) then
		xyz:CompleteProcedure()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mat=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(ODD_EYES_SET) and c:IsMonster() end,tp,LOCATION_GRAVE,0,1,1,nil)
		if #mat>0 then
			Duel.Overlay(xyz,mat)
		end
	end
	Duel.SpecialSummonComplete()
end

-- GY effect target: place cross counter on Cross Z monster you control
function s.ctfilter(c)
	return c:IsFaceup() and c:IsCode(CROSS_Z_ID)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local tc=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		tc:AddCounter(CROSS_COUNTER,1)
	end
end
