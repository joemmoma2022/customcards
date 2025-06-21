local s,id=GetID()
function s.initial_effect(c)
	-- Activate during opponent's turn, target 1 Spell/Trap, destroy it next End Phase and inflict 1000 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Only during opponent's turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Target 1 Spell/Trap your opponent controls
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
end

-- Delay destruction and damage to next opponent's End Phase
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end

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
		if tc and tc:IsOnField() and tc:IsControler(1-tp) then
			Duel.Destroy(tc,REASON_EFFECT)
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
		e:Reset()
	end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e1:SetLabelObject(tc)
	Duel.RegisterEffect(e1,tp)
end
