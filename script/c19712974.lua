--牙鮫帝シャーク・カイゼル
--Shark Caesar Kaiser
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x2e)

	-- Xyz Summon procedure: 3+ Level 4 WATER monsters or 1 "Shark Caesar"
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,3,s.ovfilter,aux.Stringid(id,1))

	-- Transfer Shark Caesar's materials when summoned using Shark Caesar
	local e_transfer=Effect.CreateEffect(c)
	e_transfer:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e_transfer:SetCode(EVENT_SPSUMMON_SUCCESS)
	e_transfer:SetOperation(s.transferop)
	c:RegisterEffect(e_transfer)

	-- This card is also treated as WATER even in Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_EXTRA)
	e1:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e1)

	-- Detach 1 material to add 1 Shark Counter (once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.ctcost)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

	-- ATK gain during damage calculation based on Shark Counters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

	-- Destruction replacement: remove 1 Shark Counter instead if has Shark Caesar as material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.repcon)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end

-- Constants
s.counter_place_list={0x2e}
s.listed_names={14306092} -- "Shark Caesar"

-- Xyz Summon overlay filter for Shark Caesar
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,14306092)
end

-- Transfer materials from Shark Caesar when overlayed
function s.transferop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	for sc in aux.Next(mg) do
		if sc:IsCode(14306092) and sc:GetOverlayCount()>0 then
			Duel.Overlay(c,sc:GetOverlayGroup())
		end
	end
end

-- Detach 1 Xyz material cost
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Add 1 Shark Counter operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x2e,1)
	end
end

-- ATK gain condition: during damage calculation
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end

-- ATK gain value: 1500 per counter if has Shark Caesar as material, else 1000 per counter
function s.atkval(e,c)
	local mult=1000
	if c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,14306092) then
		mult=1500
	end
	return c:GetCounter(0x2e)*mult
end

-- Destruction replacement condition: if has Shark Caesar as material
function s.repcon(e)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,14306092)
end

-- Destruction replacement target: can remove counter to prevent destruction
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE)
		and c:IsCanRemoveCounter(tp,0x2e,1,REASON_EFFECT) end
	return true
end

-- Destruction replacement operation: remove 1 Shark Counter
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x2e,1,REASON_EFFECT)
end
