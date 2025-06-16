-- Dissonant Note Token
-- Scripted by You
local s,id=GetID()

function s.initial_effect(c)
	-- Cannot be Tributed except for Melodious Maestra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.rellimit)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)

	-- Cannot be used as material except for Melodious monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(s.matlimit)
	c:RegisterEffect(e3)
end

-- Tribute Limit: Only for Melodious Maestra (Level 6+)
function s.rellimit(e,c)
	return not (c:IsSetCard(0x9b) and c:IsLevelAbove(6))
end

-- Material Limit: Only for Melodious
function s.matlimit(e,c)
	return not c:IsSetCard(0x9b)
end
