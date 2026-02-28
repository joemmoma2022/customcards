--Assault Bind Armor
local s,id=GetID()
function s.initial_effect(c)
	--Activate and equip to lowest ATK opponent monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	--Equip limit (only opponent's monster)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)

	--Force Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)

	--DEF becomes 0
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e4:SetValue(0)
	c:RegisterEffect(e4)

	--Cannot be destroyed by battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)

	--Burn when equipped monster is attacked
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_BE_BATTLE_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.damcon)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)

	--Banish when leaves the field
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e7)
end

--Face-up opponent monsters
function s.lowatkfilter(c)
	return c:IsFaceup()
end

--Target lowest ATK (player chooses among ties)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.lowatkfilter,tp,0,LOCATION_MZONE,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)

	local g=Duel.GetMatchingGroup(s.lowatkfilter,tp,0,LOCATION_MZONE,nil)
	local minatk=g:GetMinGroup(Card.GetAttack)

	-- Player chooses among tied lowest ATK
	Duel.SelectTarget(tp,function(c) return minatk:IsContains(c) end,
		tp,0,LOCATION_MZONE,1,1,nil)
end

--Equip operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end

	Duel.Equip(tp,c,tc)
end

--Equip limit
function s.eqlimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer())
end

--Burn condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and Duel.GetAttackTarget()==ec
end

--Burn operation
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end