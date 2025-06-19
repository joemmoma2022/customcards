local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	-- Cannot be negated
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.unnegatable_condition)
	e1:SetCost(s.unnegatable_cost)
	c:RegisterEffect(e1)
end

-- Make activation/effect unnegatable
function s.unnegatable_condition(e,tp,eg,ep,ev,re,r,rp)
	return true -- Always allows activation
end
function s.unnegatable_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Prevent activation/effect from being negated
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(1)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	Duel.RegisterEffect(e2,tp)
end

-- Filters any S/T that is destructible or can be set
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsDestructable() or c:IsAbleToChangePosition())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	if tc:IsFacedown() then
		Duel.ConfirmCards(tp,tc)
	end

	if tc:IsSetCard(0x772) or tc:IsSetCard(0x776) then
		Duel.Destroy(tc,REASON_EFFECT)
	else
		Duel.ChangePosition(tc,POS_FACEDOWN)
	end
end
