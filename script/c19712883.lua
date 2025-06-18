-- Ancient Gear Grease Injector
-- Scripted by You
local s,id=GetID()
local GREASED_GOLEM_ID=19712882
local ANCIENT_GEAR_GOLEM_ID=83104731
local ANCIENT_GEAR_ARCHETYPE=0x7

function s.initial_effect(c)
	-- Equip only to an "Ancient Gear" monster
	aux.AddEquipProcedure(c,nil,function(c) return c:IsSetCard(ANCIENT_GEAR_ARCHETYPE) end)

	-- Ignition effect: search + bonus if equipped to Ancient Gear Golem
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ATK gain for Greased Golem
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- If destroyed, equip to a Greased Golem and banish when it leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.eqcon2)
	e3:SetTarget(s.eqtg2)
	e3:SetOperation(s.eqop2)
	c:RegisterEffect(e3)
end

-- e1 condition: only while equipped to Ancient Gear Golem
function s.thcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(ANCIENT_GEAR_GOLEM_ID)
end

-- e1 search target
function s.thfilter(c)
	return c:IsCode(GREASED_GOLEM_ID) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- e1 search + extra summon + tribute boost
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not ec:IsFaceup() or not ec:IsCode(ANCIENT_GEAR_GOLEM_ID) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)

		-- Extra Normal Summon this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		-- Equipped monster can be 2 tributes for Ancient Gear monster
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
		e2:SetValue(function(e,c) return c:IsSetCard(ANCIENT_GEAR_ARCHETYPE) end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end

-- e2: ATK boost for Greased Golem based on YOUR GY only
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(GREASED_GOLEM_ID)
end
function s.atkval(e,c)
	local tp=c:GetControler()
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,ANCIENT_GEAR_ARCHETYPE)
	return ct*500
end

-- e3: Re-equip to Greased Golem if destroyed
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.eqfilter2(c)
	return c:IsFaceup() and c:IsCode(GREASED_GOLEM_ID)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	Duel.Equip(tp,c,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
end
