--Fire Formation: Summon the Flame
--Scripted by [Your Name]
local s,id=GetID()
local KING_BEETLE_ID=19712965
local ARMOR_ID=19712964

function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	--Startup effect: Add King Beetle and Sacred Armor
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startup)
	c:RegisterEffect(e1)
end

-- Startup: add cards at the start of the duel
function s.startup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add King Beetle to Extra Deck
	local beetle=Duel.CreateToken(tp,KING_BEETLE_ID)
	Duel.SendtoDeck(beetle,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Sacred Armor to Main Deck and shuffle
	local armor=Duel.CreateToken(tp,ARMOR_ID)
	Duel.SendtoDeck(armor,tp,SEQ_DECKSHUFFLE,REASON_RULE)
end

-- Flip condition: must have Fire Formation and Fire Fist monster in hand
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(s.ffcondition,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.fffilter,tp,LOCATION_HAND,0,1,nil,e,tp)
end

-- Fire Formation filter
function s.ffcondition(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL)
end

-- Fire Fist summonable monster filter
function s.fffilter(c,e,tp)
	return c:IsSetCard(0x79)
		and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Skill effect: destroy and summon
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)

	-- Select and destroy a Fire Formation
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.ffcondition,tp,LOCATION_SZONE,0,1,1,nil)
	if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end

	Duel.BreakEffect()

	-- Special Summon a Fire Fist monster from hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.fffilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
