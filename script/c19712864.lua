local s,id=GetID()
local HYPERION_ID=55794644
local SANCTUARY_ID=56433456

function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x44),1,1,aux.FilterBoolFunction(Card.IsCode,HYPERION_ID),1,1)

	--Alternative Synchro Summon using materials from hand if Sanctuary is on field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetOperation(s.altop)
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e0)

	--Banish Spell to recover Sanctuary or card that mentions it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- desc1
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--Battle indestructible if Sanctuary is face-up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.sanctuarycond)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	--Destroy opponent's card & burn 500 per banished Fairy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1)) -- desc2
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(2,id+100)
	e3:SetCondition(s.sanctuarycond)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

--Alternative Synchro Summon condition
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()

	-- Sanctuary must be face-up
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,SANCTUARY_ID),tp,LOCATION_ONFIELD,0,1,nil) then return false end

	-- Get all valid materials
	local tuners=Duel.GetMatchingGroup(s.tunerfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local hyperions=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,HYPERION_ID)

	-- Check for any pair that matches level and has at least one from hand
	for t in aux.Next(tuners) do
		for h in aux.Next(hyperions) do
			if t:GetLevel()+h:GetLevel()==c:GetLevel() then
				if t:IsLocation(LOCATION_HAND) or h:IsLocation(LOCATION_HAND) then
					return true
				end
			end
		end
	end

	return false
end

--Filter for "The Agent" Tuners
function s.tunerfilter(c)
	return c:IsSetCard(0x44) and c:IsType(TYPE_TUNER)
end

--Alternative Synchro Summon operation
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	-- Select valid Tuner
	local g1=Duel.SelectMatchingCard(tp,s.tunerfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tuner=g1:GetFirst()
	if not tuner then return end

	-- Select valid Hyperion with matching level
	local lv=c:GetLevel()-tuner:GetLevel()
	local g2=Duel.SelectMatchingCard(tp,function(card)
		return card:IsCode(HYPERION_ID) and card:GetLevel()==lv
	end,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)

	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_MATERIAL+REASON_SYNCHRO)
end

--Cost: Banish 1 Spell from hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end

--Target a "Sanctuary"-related card in GY or banished
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsCode(SANCTUARY_ID) or c:ListsCode(SANCTUARY_ID))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Sanctuary must be face-up
function s.sanctuarycond(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,SANCTUARY_ID),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

--Destroy 1 opponent's card and burn
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fairyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.fairyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fairyfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_FAIRY)
		if ct>0 then
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
end
