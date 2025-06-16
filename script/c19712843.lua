local s,id=GetID()
local ARC_MAG_ID=31924889

function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)

	-- Synchro Summon procedure: 1 Tuner + 1 Synchro monster
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,1,
		aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),1,1)
	c:EnableReviveLimit()

	-- On Synchro Summon: gain 3 Spell Counters if Arcanite Magician was used
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

	-- Gain 1000 ATK per Spell Counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(function(e,c) return c:GetCounter(COUNTER_SPELL)*1000 end)
	c:RegisterEffect(e2)

	-- Remove 1 Counter → declare Attribute → destroy → inflict 1000
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end

-- Check if Arcanite Magician was used as Synchro Material
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(Card.IsCode,1,nil,ARC_MAG_ID)
end

-- Add 3 Spell Counters
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_SPELL,3)
end

-- Cost: Remove 1 Spell Counter
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end

-- Choose Attribute to destroy
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_EARTH+ATTRIBUTE_FIRE+ATTRIBUTE_WATER+ATTRIBUTE_WIND)
	e:SetLabel(attr)
end

-- Destroy matching monster and deal 1000 damage
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	local g=Duel.SelectMatchingCard(tp,function(c) return c:IsAttribute(attr) and c:IsDestructable() end,
		tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
