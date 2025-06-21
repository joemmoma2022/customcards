--Mantis Broodmother
local s,id=GetID()
local TOKEN_BABY_MANTIS=511009033

function s.initial_effect(c)
	-- Special Summon from hand by tributing 1 "Mantis" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Discard to summon Baby Mantis Tokens to either side
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x535}

function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x535) and c:IsReleasable()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
	end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,63,REASON_COST+REASON_DISCARD)
	local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	e:SetLabel(ct)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0x535,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if not ct or ct <= 0 then return end
	local ft1 = Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2 = Duel.GetLocationCount(1-tp,LOCATION_MZONE)

	if ft1 + ft2 < ct then return end

	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_BABY_MANTIS)

		local summon_to=nil
		-- Decide where to summon the token
		if ft1 > 0 and ft2 > 0 then
			-- Both sides have space, ask player
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			if Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
				summon_to = 1 - tp
				ft2 = ft2 - 1
			else
				summon_to = tp
				ft1 = ft1 - 1
			end
		elseif ft1 > 0 then
			summon_to = tp
			ft1 = ft1 - 1
		elseif ft2 > 0 then
			summon_to = 1 - tp
			ft2 = ft2 - 1
		else
			-- No space left on either side, stop summoning tokens
			break
		end

		if Duel.SpecialSummonStep(token,0,summon_to,summon_to,false,false,POS_FACEUP) then
			-- Restrict tribute to Insect only
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(s.ntrib)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)

			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2)

			-- Schedule destruction during next End Phase
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCountLimit(1)
			e3:SetLabelObject(token)
			e3:SetCondition(s.descon)
			e3:SetOperation(s.desop)
			e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
			Duel.RegisterEffect(e3,summon_to)
		else
			token:RemoveSelf()
		end
	end
	Duel.SpecialSummonComplete()
end

function s.ntrib(e,c)
	return not c:IsRace(RACE_INSECT)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
