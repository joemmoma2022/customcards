--Wind-Up Blaster (Cost-Based Damage)
local s,id=GetID()
function s.initial_effect(c)
	--activation
   	local e1=Effect.CreateEffect(c)
   	e1:SetType(EFFECT_TYPE_ACTIVATE)
    	e1:SetCode(EVENT_FREE_CHAIN)
    	c:RegisterEffect(e1)	
	-- Allow Wind-Up Counter (0x898)
	c:EnableCounterPermit(0x898)

	-- (1) During your Standby Phase: Gain 1 Wind-Up Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

	-- (2) Send to GY as cost: Deal damage depending on counters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.damcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end

-- (1) Gain 1 Wind-Up Counter during your Standby Phase
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x898,1)
	end
end

-- (2) Cost: Send this card to the GY and store counter info before sending
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	local ct = c:GetCounter(0x898)
	local val = (ct > 0) and 700 or 200
	e:SetLabel(val)
	Duel.SendtoGrave(c,REASON_COST)
end

-- Target setup for damage
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local val = e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end

-- Deal the stored damage
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local val = e:GetLabel()
	Duel.Damage(1-tp,val,REASON_EFFECT)
end
