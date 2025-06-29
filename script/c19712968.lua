--Custom Insect Monster
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Special Summon from hand by destroying 2 face-up Insect monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- MATERIAL_CHECK to sum destroyed monsters' printed ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)

	-- SUMMON_COST triggers MATERIAL_CHECK
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetOperation(s.facechk)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)

	-- Quick Effect: Banish 1 Insect in GY; gain its ATK until end phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	-- Indestructible while Mantis Baby Token exists
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	local e6=e3:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e6)
end

-- Filter for destructible Insect monsters
function s.insectfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsDestructable()
end

-- Special Summon condition: destroy 2 Insect monsters on your field
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.insectfilter,tp,LOCATION_MZONE,0,nil)
	return #g>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

-- Destroy 2 Insects as cost to Special Summon
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.insectfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=g:Select(tp,2,2,nil)
	c:SetMaterial(dg)
	Duel.Destroy(dg,REASON_COST)
end

-- Sum printed ATK of destroyed monsters
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	for tc in aux.Next(g) do
		local catk=tc:GetTextAttack()
		atk = atk + (catk >= 0 and catk or 0)
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end

function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

-- Banish Insect to gain its ATK
function s.gyfilter(c)
	return c:IsRace(RACE_INSECT) and c:GetAttack()>0 and c:IsAbleToRemove()
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		e:SetLabel(g:GetFirst():GetAttack())
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- Indestructible while Mantis Baby Token is face-up on field
function s.indcon(e)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(19712975)
	end, e:GetHandlerPlayer(), LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end
