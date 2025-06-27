local s,id=GetID()
function s.initial_effect(c)
	-- Activation (Quick during opponent's turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Only activate during opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Target 1 monster your opponent controls
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end

-- Set up delayed destruction and damage at opponent's next End Phase
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end

	-- Store the turn count to track "next End Phase"
	local turn_id=Duel.GetTurnCount()

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnPlayer()==1-tp and Duel.GetTurnCount()>turn_id
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tc=e:GetLabelObject()
		if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsOnField() then
			Duel.Destroy(tc,REASON_EFFECT)
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
		e:Reset()
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e1:SetLabelObject(tc)
	Duel.RegisterEffect(e1,tp)
end
