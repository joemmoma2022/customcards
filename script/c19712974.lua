--牙鮫帝シャーク・カイゼル
--Shark Caesar
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x2e)
	-- Xyz Summon procedure: 3+ Level 4 WATER monsters or with "Shark Caesar"
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,3,s.ovfilter,aux.Stringid(id,1))

	-- Also treated as WATER
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_ADD_ATTRIBUTE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e4)

	-- Add 1 Shark Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.ctcost)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

	-- ATK gain based on Shark Counters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Protection: if it has Shark Caesar, remove 1 counter instead of destruction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.repcon)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)

	-- Attach "Shark" monsters from GY if Special Summoned from GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.gycon)
	e5:SetOperation(s.gyop)
	c:RegisterEffect(e5)
end

-- Constants
s.counter_place_list={0x2e}
s.listed_names={14306092} -- "Shark Caesar"

-- Xyz: allow using "Shark Caesar" as material
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,14306092)
end

-- Detach to add counter
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x2e,1)
	end
end

-- ATK boost during battle
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
function s.atkval(e,c)
	local mult=1000
	if c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,14306092) then
		mult=1500
	end
	return c:GetCounter(0x2e)*mult
end

-- Destruction replacement effect if has Shark Caesar
function s.repcon(e)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,14306092)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsCanRemoveCounter(tp,0x2e,1,REASON_EFFECT) end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x2e,1,REASON_EFFECT)
end

-- Check if summoned from GY
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetPreviousLocation()==LOCATION_GRAVE
end

-- Attach "Shark" monsters from GY
function s.sharkfilter(c)
	return c:IsSetCard(0x547) and c:IsMonster()
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sharkfilter),tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=g:Select(tp,1,ct,nil)
	if #sg>0 then
		Duel.Overlay(c,sg)
	end
end
