--Mantis Queen Matriarch
local s,id=GetID()
local TOKEN_BABY_MANTIS=511009033

function s.initial_effect(c)
	-- Special Summon from hand by tributing 2 Baby Mantis Tokens
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

	-- Tribute 3 Tokens to destroy 3 cards
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

-- Filter: Baby Mantis Token releasable for summoning this card
function s.tokenfilter(c,summoning_card)
	if c:IsCode(TOKEN_BABY_MANTIS) then
		if summoning_card then
			if not summoning_card:IsRace(RACE_INSECT) then return false end
			return c:IsReleasable() or c:IsType(TYPE_TOKEN)
		else
			return c:IsReleasable()
		end
	else
		return c:IsReleasable()
	end
end

-- Special Summon Condition: Tribute 2 Baby Mantis Tokens (from either field)
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(function(card) return s.tokenfilter(card,c) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>=2
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(function(card) return s.tokenfilter(card,c) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:Select(tp,2,2,nil)
	Duel.Release(rg,REASON_COST)
end

-- Filter for Baby Mantis Tokens only (for destruction effect)
function s.dest_tokenfilter(c)
	return c:IsCode(TOKEN_BABY_MANTIS) and c:IsFaceup() and c:IsReleasable()
end

-- Destroy effect: Tribute 3 Baby Mantis Tokens (from either side) to destroy 3 cards
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroupCount(s.dest_tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil) >= 3
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,3,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,3,0,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dest_tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g < 3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:Select(tp,3,3,nil)
	if Duel.Release(rg,REASON_COST) == 3 then
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,3,nil)
		if #dg > 0 then
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
