local s,id=GetID()

function s.initial_effect(c)
	-- Destroy attacking monster after damage calculation and inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_END)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=Duel.GetAttacker()
	return c==Duel.GetAttackTarget() and at and at:IsControler(1-tp) and c:IsFaceup() and at:IsRelateToBattle()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsRelateToBattle() and at:IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	local dmg=math.floor(at:GetAttack()/2)
	Duel.SetTargetParam(dmg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at and at:IsRelateToBattle() and Duel.Destroy(at,REASON_EFFECT)~=0 then
		local dmg=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		Duel.Damage(1-tp,dmg,REASON_EFFECT)
	end
end
