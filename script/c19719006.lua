local s,id=GetID()
local POLY_ID=19712850 -- Poly-Chemicritter NitrHopper
local VOLA_ID=19712851 -- Vola-Chemicritter HydroxLiner
local FIELD_ID=65959844 -- Catalyst Field
local CHEMICRITTER_SET=0xeb -- Chemicritter archetype set code
local OPT_FLAG=id+1000 -- Separate integer for once-per-turn flag

function s.initial_effect(c)
	-- Register skill with 2 uses per duel (adjust if needed)
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop,1)

	-- Startup effect: add Extra Deck cards and place field
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f) -- Skill zone
	e1:SetOperation(s.startup)
	c:RegisterEffect(e1)

	-- Continuous effect: Gemini Chemicritter monsters treated as Effect Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.gemini_target)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
end

-- Startup operation
function s.startup(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Poly and Vola to Extra Deck (outside duel cards)
	local poly=Duel.CreateToken(tp,POLY_ID)
	local vola=Duel.CreateToken(tp,VOLA_ID)
	Duel.SendtoDeck(poly,tp,SEQ_DECKTOP,REASON_RULE)
	Duel.SendtoDeck(vola,tp,SEQ_DECKTOP,REASON_RULE)

	-- Place Catalyst Field from Deck to field zone
	local g=Duel.GetMatchingGroup(function(c) return c:IsCode(FIELD_ID) end,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

-- Target function for Gemini Chemicritter monsters
function s.gemini_target(e,c)
	return c:IsSetCard(CHEMICRITTER_SET) and c:IsGeminiState()
end

-- Skill activation condition for OPT attach effect
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.GetFlagEffect(tp, OPT_FLAG)==0 -- once per turn
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- Skill operation: Attach GY monster as Xyz material
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Select your "Chemicritter" Xyz monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not xyz or xyz:IsFacedown() then return end

	-- Select a "Chemicritter" monster in GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(xyz,g)
	end

	-- Mark skill as used this turn
	Duel.RegisterFlagEffect(tp, OPT_FLAG, RESET_PHASE+PHASE_END, 0, 1)
end

-- Filters
function s.xyzfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(CHEMICRITTER_SET)
end
function s.gyfilter(c)
	return c:IsSetCard(CHEMICRITTER_SET)
end
