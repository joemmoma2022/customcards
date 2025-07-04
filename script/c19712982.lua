local s,id=GetID()
local EQUIP_CARD_ID=6205579 -- Fusion Parasite
local DOZER_ID=76039636 -- Doom Dozer

function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,6205579,76039636)
	
-- Direct attack if equipped with Fusion Parasite
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)

	-- Mark flag when equipped with Fusion Parasite (to identify the direct attack source)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_EQUIP)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsCode,1,nil,EQUIP_CARD_ID)
	end)
	e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
	end)
	c:RegisterEffect(e0)

	-- Remove flag when leaves the field
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0x:SetCode(EVENT_LEAVE_FIELD)
	e0x:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():ResetFlagEffect(id)
	end)
	c:RegisterEffect(e0x)

	-- Halve battle damage when attacking directly if direct attack granted by equip
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e2)

	-- Banish top card of opponent's deck when inflicting battle damage by direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(s.rmvcon)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)

	-- Special summon self from GY by banishing 2 Insect monsters from GY if no monsters on your field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

-- Check if equipped with Fusion Parasite
function s.dircon(e)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	return eqg:IsExists(Card.IsCode,1,nil,EQUIP_CARD_ID)
end

-- Halve damage only if direct attack granted by equip (flag set)
function s.rdcon(e)
	local c=e:GetHandler()
	return Duel.GetAttackTarget()==nil and c:GetFlagEffect(id)>0
end

-- Banish top card of opponent's deck when inflicting battle damage by direct attack
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end

function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end

function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 then
		local g=Duel.GetDecktopGroup(1-tp,1)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

-- Special summon condition: no monsters on your field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- Cost: banish 2 Insect monsters from your GY
function s.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Target self for special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- Special summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end