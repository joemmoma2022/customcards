--Fire Formation - Sacred Ritual
local s,id=GetID()

function s.initial_effect(c)
	-- Activate and Xyz Summon Sacred King Beetle
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ATK Boost for all your monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

-- Correct Tiger King code
local TIGER_KING_ID=96947648
local BEETLE_ID=19712965

-- Tiger King filter
function s.tigerfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(TIGER_KING_ID)
		and Duel.IsExistingMatchingCard(s.beetlefilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

-- Sacred King Beetle filter
function s.beetlefilter(c,e,tp,mc)
	return c:IsCode(BEETLE_ID) and mc:IsCanBeXyzMaterial(c)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- Target function
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tigerfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tigerfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tigerfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end

-- Activation logic
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsControler(tp) then return end

	-- Get valid Sacred King Beetle from Extra Deck
	local g=Duel.GetMatchingGroup(s.beetlefilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if not sc then return end

	local mg=tc:GetOverlayGroup()

	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:SetMaterial(Group.FromCards(tc))
		if #mg>0 then
			Duel.Overlay(sc,mg)
		end
		Duel.Overlay(sc,tc)
		sc:CompleteProcedure()

		-- Equip this card to the summoned Beetle
		if not c:IsRelateToEffect(e) or not sc:IsFaceup() then return end
		if not Duel.Equip(tp,c,sc) then return end

		-- Restrict equip to Beetle only
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(function(e,c) return c:IsCode(BEETLE_ID) end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

-- ATK gain based on Beetle's materials
function s.atkval(e,c)
	local tp=c:GetControler()
	local beetles=Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and c:IsCode(BEETLE_ID)
	end,tp,LOCATION_MZONE,0,nil)
	local count=0
	for bc in aux.Next(beetles) do
		count=count + bc:GetOverlayCount()
	end
	return count*100
end
