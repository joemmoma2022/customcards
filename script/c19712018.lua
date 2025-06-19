local s,id=GetID()
function s.initial_effect(c)
	-- Activate in response to damage or effect that would reduce LP to 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Also allow activation in response to battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.battlecon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

-- Condition for chain damage that would reduce LP to 0 or less
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then return false end -- opponent's turn only
	if ep~=tp then return false end -- damage to you
	if not re or not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then return false end
	local ex,_,dam=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and dam and dam>=Duel.GetLP(tp) then
		return true
	end
	return false
end

-- Condition for battle damage that would reduce LP to 0 or less
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then return false end -- opponent's turn only
	return ep==tp and Duel.GetLP(tp)<=ev and ev>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SetLP(tp,1)
	if e:GetCode()==EVENT_PRE_BATTLE_DAMAGE then
		Duel.ChangeBattleDamage(tp,0)
	end
	-- End opponent's turn immediately
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_END,RESET_PHASE+PHASE_END,1)
	-- Banish this card instead of sending to GY
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end
