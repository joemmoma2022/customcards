-- Gem-Knight Legacy Skill
-- Scripted by ChatGPT
local s,id=GetID()

local INF_CRYSTAL=19712840
local INFERNO_COUNTER=0x1319
local INFERNO_BEETLE=19712855  -- Replace this with the correct card ID for Gem-Mech God Beetle

InfernoCrystalMaterialSub = {}

function s.initial_effect(c)
	-- Flip skill at start
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Start of Duel setup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)

	-- Apply passive effects while Inferno Crystal has 3+ counters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(0x5f)
	e2:SetOperation(s.passivecheck)
	c:RegisterEffect(e2)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Gem-Knight Inferno Crystal to Extra Deck face-down
	local inferno=Duel.CreateToken(tp,INF_CRYSTAL)
	Duel.SendtoDeck(inferno,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Gem-Mech God Beetle to hand at start of duel
	local beetle=Duel.CreateToken(tp,INFERNO_BEETLE)
	Duel.SendtoHand(beetle,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,beetle)

	-- Add 1 "Gem-Knight" Normal Monster from Deck to hand
	local g=Duel.GetMatchingGroup(s.gemknightnormfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sel=g:Select(tp,1,1,nil):GetFirst()
		if sel then
			Duel.SendtoHand(sel,tp,REASON_RULE)
			Duel.ConfirmCards(1-tp,sel)
		end
	end

	-- Enable alternate material substitution for Inferno Crystal fusion summon
	InfernoCrystalMaterialSub[tp] = true
end

function s.gemknightnormfilter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.inferno_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,0)}, -- Add Inferno Counter
		{false,aux.Stringid(id,1)} -- Cancel
	)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,s.inferno_filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			tc:AddCounter(INFERNO_COUNTER,1)
		end
	end
end

function s.inferno_filter(c)
	return c:IsFaceup() and c:IsCode(INF_CRYSTAL)
end

-- Passive effects while Inferno Crystal has 3+ counters
function s.passivecheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.inferno_filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if tc:GetCounter(INFERNO_COUNTER)>=3 then
			-- Inferno Crystal cannot be destroyed by card effects (until end phase)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)

			-- Gem-Knight Normals can't be destroyed by battle (until end phase)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(function(e,c) return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) end)
			e2:SetValue(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)

			-- Once per turn: Special Summon a Gem-Knight Normal from GY
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,2))
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e3:SetCountLimit(1)
			e3:SetRange(0x5f)
			e3:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.revivefilter,tp,LOCATION_GRAVE,0,1,nil) end)
			e3:SetOperation(s.reviveop)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
	end
end

function s.revivefilter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end

function s.reviveop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.revivefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
