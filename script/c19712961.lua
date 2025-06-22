--Royal Cookpal Retribution
local s,id=GetID()
function s.initial_effect(c)
	--Activate: burn equal to ATK of monsters destroyed by "Royal Cookpal" monster effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)

	-- Global check for destruction tracking
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		-- Track destroyed monsters
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.damop)
		Duel.RegisterEffect(ge1,0)
		-- Reset on adjust (once per turn)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0x1512} -- Royal Cookpal

-- Check if monster was destroyed by Royal Cookpal effect
function s.chkfilter(c,tp,re)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and re and re:GetOwner():IsSetCard(0x1512)
end

-- Track damage from destroyed monsters
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(s.chkfilter,nil,tp,re)
	local g2=eg:Filter(s.chkfilter,nil,1-tp,re)
	if #g1>0 then
		s[tp] = s[tp] + g1:GetSum(Card.GetAttack)
	end
	if #g2>0 then
		s[1-tp] = s[1-tp] + g2:GetSum(Card.GetAttack)
	end
end

-- Reset at start of turn
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s[0]>0 or s[1]>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s[0]>0 then Duel.Damage(0,s[0],REASON_EFFECT) end
	if s[1]>0 then Duel.Damage(1,s[1],REASON_EFFECT) end
end
