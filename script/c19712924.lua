--Mantis Devourer
local s,id=GetID()
local TOKEN_BABY_MANTIS=19712975

function s.initial_effect(c)
	-- Special Summon from hand by destroying 1 Baby Mantis Token from either field
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

	-- Destroy 1 Baby Mantis Token to destroy 1 opponent's card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

-- Filter: face-up destructible Baby Mantis Tokens on either field
function s.tokenfilter(c)
	return c:IsFaceup() and c:IsCode(TOKEN_BABY_MANTIS) and c:IsDestructable()
end

-- Special summon condition: destroy 1 Baby Mantis Token on either field
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		c:SetMaterial(g)
		Duel.Destroy(g,REASON_COST)
	end
end

-- Destroy effect: destroy 1 Baby Mantis Token to destroy 1 opponent's card
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local rg=Duel.SelectMatchingCard(tp,s.tokenfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #rg>0 and Duel.Destroy(rg,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
