local s,id=GetID()
local FUSION_PARASITE_CODE=6205579

function s.initial_effect(c)
	-- While face-up on field, treat as Fusion Monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(TYPE_FUSION)
	c:RegisterEffect(e0)

	-- Special Summon from hand by discarding a Fusion Parasite
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon_hand)
	e1:SetOperation(s.spop_hand)
	c:RegisterEffect(e1)

	-- Fusion Substitute effect (like the anime card)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(s.subcon)
	c:RegisterEffect(e2)

	-- Mark this card for fusion summon helper
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(id)
	e3:SetRange(LOCATION_ONFIELD)
	c:RegisterEffect(e3)

	-- Fusion Summon on Special Summon
	local params = {gc=Fusion.ForcedHandler,stage2=s.stage2}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.spcon)
	e4:SetTarget(Fusion.SummonEffTG(params))
	e4:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e4)

	-- Destruction replacement effect when equipped
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e5:SetValue(s.repval)
	c:RegisterEffect(e5)
end

-- Special summon condition from hand by discarding Fusion Parasite monster
function s.spfilter(c)
	return c:IsOriginalCodeRule(FUSION_PARASITE_CODE) and c:IsDiscardable()
end
function s.spcon_hand(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c)
end
function s.spop_hand(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

-- Fusion Substitute condition
function s.subcon(e)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsOnField()
end

-- Fusion Summon trigger condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end

-- Equip limit function for stage2
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end

-- Fusion Summon stage2: equip this card + 1 Fusion Parasite from GY to the summoned fusion monster
function s.stage2(e,tc,tp,sg,chk)
	local c=e:GetHandler()
	if chk==1 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsLocation(LOCATION_GRAVE)
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	if not tc or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsLocation(LOCATION_GRAVE) then return end
	
	-- Equip this Fusion Parasite card
	if not Duel.Equip(tp,c,tc,false) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)

	-- Grant once per turn indestructible effect to equipped monster
	local e_prot=Effect.CreateEffect(c)
	e_prot:SetType(EFFECT_TYPE_EQUIP)
	e_prot:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e_prot:SetCountLimit(1)
	e_prot:SetValue(function(e,re,r,rp)
		return (r & REASON_BATTLE+REASON_EFFECT)~=0
	end)
	e_prot:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e_prot)

	-- Equip another Fusion Parasite monster from GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,c)
	local eqc=g:GetFirst()
	if eqc then
		if Duel.Equip(tp,eqc,tc,false) then
			local e2=Effect.CreateEffect(eqc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(function(e,c2) return c2==tc end)
			eqc:RegisterEffect(e2)
		end
	end
end

-- Filter for Fusion Parasite in GY to equip
function s.eqfilter(c)
	return c:IsCode(FUSION_PARASITE_CODE) and c:IsType(TYPE_MONSTER)
end

-- Destruction substitution: equipped monster can't be destroyed by battle or card effect once
function s.repval(e,re,r,rp)
	return (r & REASON_BATTLE+REASON_EFFECT) ~= 0
end
