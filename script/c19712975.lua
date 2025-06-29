--Baby Mantis Token
local s,id=GetID()

function s.initial_effect(c)
	-- Cannot be tributed except for the Summon or Effect of an Insect monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e1:SetValue(1) -- Completely prevents non-summon release
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(s.sumlimit)
	c:RegisterEffect(e2)

	-- Optional: prevent it from being used as Synchro Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

-- Only allow tributing for Insect monsters
function s.sumlimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
