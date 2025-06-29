--Mantis Devourer
local s,id=GetID()
local TOKEN_BABY_MANTIS=511009033

function s.initial_effect(c)
	-- Special Summon from hand by tributing 1 Baby Mantis Token from either field
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

	-- Tribute 1 Baby Mantis Token to destroy 1 opponent's card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

-- Filter for Baby Mantis Token releasable for summoning this card
function s.tokenfilter(c,summoning_card)
	if c:IsCode(TOKEN_BABY_MANTIS) then
		if summoning_card then
			-- Only allow if summoning card is Insect and token is releasable or token can be tributed for insects
			if not summoning_card:IsRace(RACE_INSECT) then return false end
			return c:IsReleasable() or c:IsType(TYPE_TOKEN)
		else
			return c:IsReleasable()
		end
	else
		return c:IsReleasable()
	end
end

-- Special summon condition: tribute 1 Baby Mantis Token on either field
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(function(card) return s.tokenfilter(card,c) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=1
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,function(card) return s.tokenfilter(card,c) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Release(g,REASON_COST)
end

-- Destroy effect: tribute 1 Baby Mantis Token to destroy 1 opponent card
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(function(c) return s.tokenfilter(c) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=Duel.SelectMatchingCard(tp,function(c) return s.tokenfilter(c) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #rg>0 and Duel.Release(rg,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
