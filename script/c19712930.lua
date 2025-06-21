local s,id=GetID()

function s.initial_effect(c)
	-- Indestructible by effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetRange(LOCATION_FZONE)
	e0:SetValue(aux.indoval)
	c:RegisterEffect(e0)

	-- Cannot be targeted by effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)

	-- Only 1 monster can attack per Battle Phase for controller
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.battlephase_start)
	c:RegisterEffect(e2)
end

function s.battlephase_start(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	local c=e:GetHandler()

	-- Create effect that prevents multiple attacks for controller
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetLabel(0) -- will store field ID of monster that attacked
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e1,p)

	-- Listen for attacks to record the first attacker
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local fid = eg:GetFirst():GetFieldID()
		e:GetLabelObject():SetLabel(fid)
		Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_BATTLE,0,1)
	end)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e2,p)
end

function s.atktg(e,c)
	return e:GetLabel()~=0 and c:GetFieldID()~=e:GetLabel()
end
