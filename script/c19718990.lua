-- Genex Synchro Surge
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Start-of-Duel setup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Create cards from outside the Duel
	local shootingWolf=Duel.CreateToken(tp,19712846)
	local caerulupus=Duel.CreateToken(tp,19712859)

	-- Add Shooting Wolf Genex to Extra Deck
	if shootingWolf then
		local g1=Group.CreateGroup()
		g1:AddCard(shootingWolf)
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Add Genex Caerulupus to hand
	if caerulupus then
		Duel.SendtoHand(caerulupus,nil,REASON_RULE)
	end

	-- Once per turn: If a "Genex" Synchro monster attacks or is attacked, destroy opponent's monster and inflict 1000 damage
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(s.battlecon)
	e2:SetOperation(s.battleop)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	Duel.RegisterEffect(e2,tp)

	-- Reset the flag at the end of your turn only
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(function(ev) return Duel.GetTurnPlayer() == tp end)
	e3:SetOperation(function(ev) Duel.ResetFlagEffect(tp,id) end)
	Duel.RegisterEffect(e3,tp)

	-- Treat all Tuner monsters you control as "Genex Controller" for Synchro Summons
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.tunertarget)
	e4:SetValue(68505803) -- Genex Controller's ID
	Duel.RegisterEffect(e4,tp)
end

-- Tuner treatment condition
function s.tunertarget(e,c)
	return c:IsType(TYPE_TUNER)
end

-- Battle condition
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	return tc:IsControler(tp) and tc:IsSetCard(0x2) and tc:IsType(TYPE_SYNCHRO)
end

-- Battle operation with once-per-turn limit
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
