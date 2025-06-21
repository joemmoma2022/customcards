local s,id=GetID()
function s.initial_effect(c)
	-- Union procedure: no filter, allows unequip and equip
	aux.AddUnionProcedure(c,nil,true)

	-- Ignition effect: equip to monster or unequip + special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e1:SetCountLimit(1,id) -- shared once per turn
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	-- ATK boost during damage step only
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1500)
	e2:SetCondition(s.damcon)
	c:RegisterEffect(e2)

	-- DEF boost during damage step only
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(2000)
	c:RegisterEffect(e3)
end

-- Damage step condition
function s.damcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end

-- Filter for equip targets (face-up monsters you control)
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
end

-- Target for equip or unequip
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if c:IsLocation(LOCATION_MZONE) then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp)
		else
			return false
		end
	end
	if chk==0 then
		if c:IsLocation(LOCATION_MZONE) then
			-- On field as monster, can try to equip
			return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,c,tp)
		elseif c:IsLocation(LOCATION_SZONE) then
			-- On field as equip, can unequip and special summon if space available
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		end
		return false
	end
	if c:IsLocation(LOCATION_MZONE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,c,tp)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	elseif c:IsLocation(LOCATION_SZONE) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end

-- Equip or unequip operation
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		-- Equip to selected target
		local tc=Duel.GetFirstTarget()
		if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
		if not Duel.Equip(tp,c,tc,false) then return end
		-- Equip limit to that target only
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==tc end)
		c:RegisterEffect(e1)
	elseif c:IsLocation(LOCATION_SZONE) then
		-- Unequip and special summon
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
			-- Reset equip limit so it no longer applies as monster
			c:ResetEffect(RESET_EQUIP_LIMIT)
		end
	end
end
