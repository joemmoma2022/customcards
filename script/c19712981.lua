-- Fusion Parasite + Number 2: Ninja Shadow Mosquito
-- Custom Fusion Monster Script by You
local s,id=GetID()

function s.initial_effect(c)
	-- Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,6205579,32453837)

	-- Place Hallucination Counters on Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

	-- Gain ATK based on total Hallucination Counters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Burn: remove 1 counter to deal 100 x each counter on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.burncon)
	e3:SetCost(s.burncost)
	e3:SetTarget(s.burntg)
	e3:SetOperation(s.burnop)
	c:RegisterEffect(e3)

	-- Opponent's monsters must attack this card if able
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(function(e,c) return c==e:GetHandler() end)
	c:RegisterEffect(e5)
end

-- Check if Fusion Summoned
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Place Hallucination Counters one by one based on Insects in GY
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_INSECT)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	for i=1,ct do
		if #g==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
			tc:AddCounter(0x1101,1)
		end
	end
end

-- Gain ATK equal to total Hallucination Counters x1000
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=0
	for tc in aux.Next(g) do
		ct=ct+tc:GetCounter(0x1101)
	end
	return ct*1000
end

-- Burn condition: at least 1 counter on field
function s.burncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,0x1101,1)
end

-- Burn cost: remove 1 Hallucination Counter
function s.burncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1101,1,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x1101,1,REASON_COST)
end

-- Burn target: total counters x100 damage
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetCounter(tp,1,1,0x1101)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end

-- Burn operation
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
