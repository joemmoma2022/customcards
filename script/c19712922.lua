--Mantis Broodmother
local s,id=GetID()
local TOKEN_BABY_MANTIS=511009033
s.listed_series={0x535}

function s.initial_effect(c)
	-- Special Summon from hand by tributing 1 "Mantis" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
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

-- Tribute 1 "Mantis" monster to Special Summon this card
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x535) and c:IsReleasable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	c:SetMaterial(g)
	Duel.Release(g,REASON_COST)
end

-- Cost: Discard any number of cards, store count
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,63,REASON_COST+REASON_DISCARD)
	e:SetLabel(ct)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct <= 0 then return end

	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	ct = math.min(ct, ft1 + ft2)

	local tokens = Group.CreateGroup()

	for i=1,ct do
		local p
		if ft1 > 0 and ft2 > 0 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- Choose who gets the token
			if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				p = 1 - tp
				ft2 = ft2 - 1
			else
				p = tp
				ft1 = ft1 - 1
			end
		elseif ft1 > 0 then
			p = tp
			ft1 = ft1 - 1
		elseif ft2 > 0 then
			p = 1 - tp
			ft2 = ft2 - 1
		else
			break
		end

		local token=Duel.CreateToken(p,TOKEN_BABY_MANTIS)
		if Duel.SpecialSummonStep(token,0,p,p,false,false,POS_FACEUP) then
			tokens:AddCard(token)

			-- Tribute limit: only for Insect monsters
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(s.rellimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)

			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2)

			-- Material limit: only for Insect monsters
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetValue(s.matlimit)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3)

			-- Flag token for later destruction tracking
			token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
	Duel.SpecialSummonComplete()

	-- Schedule destruction during the controller's next End Phase after this turn
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetLabel(Duel.GetTurnCount())
	e3:SetLabelObject(tokens)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	Duel.RegisterEffect(e3,tp)
end

-- Tribute restriction: can only be tributed for Insect monsters
function s.rellimit(e,c)
	return not c:IsRace(RACE_INSECT)
end

-- Material restriction: can only be used as material for Insect monsters
function s.matlimit(e,c)
	return not c:IsRace(RACE_INSECT)
end

-- Destruction condition: only on your next End Phase after this one
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local turn=e:GetLabel()
	local tokens=e:GetLabelObject()
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=turn and tokens:IsExists(Card.IsFaceup,1,nil)
end

-- Destroy the tokens
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tokens=e:GetLabelObject()
	local tg=tokens:Filter(Card.IsFaceup,nil)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
