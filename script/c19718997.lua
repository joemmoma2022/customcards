local s,id=GetID()

local INF_CRYSTAL=19712840
local INFERNO_COUNTER=0x1319

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)

	-- Startup effect
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)

	-- Passive effect: Protection and battle immunity
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(_,c) return c:IsCode(INF_CRYSTAL) and c:GetCounter(INFERNO_COUNTER)>=3 end)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,0)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(_,c) return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and Duel.IsExistingMatchingCard(s.crystal_with_3_counters,c:GetControler(),LOCATION_MZONE,0,1,nil) end)
	e3:SetValue(1)
	Duel.RegisterEffect(e3,0)
end

function s.crystal_with_3_counters(c)
	return c:IsFaceup() and c:IsCode(INF_CRYSTAL) and c:GetCounter(INFERNO_COUNTER)>=3
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Inferno Crystal token face-down to Extra Deck
	local inferno=Duel.CreateToken(tp,INF_CRYSTAL)
	Duel.SendtoDeck(inferno,tp,SEQ_DECKTOP,REASON_RULE)

	-- Add Gem-Mech God Beetle to hand
	local beetle=Duel.CreateToken(tp,19712855)
	Duel.SendtoHand(beetle,tp,REASON_RULE)
	Duel.ConfirmCards(1-tp,beetle)

	-- Add 1 Normal Gem-Knight from Deck to hand
	local g=Duel.GetMatchingGroup(s.gemknightnormfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sel=g:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoHand(sel,tp,REASON_RULE)
		Duel.ConfirmCards(1-tp,sel)
	end
end

function s.gemknightnormfilter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end

function s.inferno_filter(c)
	return c:IsFaceup() and c:IsCode(INF_CRYSTAL)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.inferno_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local inferno=Duel.GetFirstMatchingCard(s.inferno_filter,tp,LOCATION_MZONE,0,nil)
	if not inferno then return end

	-- Add 1 Inferno Counter
	inferno:AddCounter(INFERNO_COUNTER,1)
	Duel.RegisterFlagEffect(tp,id*100,RESET_PHASE+PHASE_END,0,1)

	-- If now has 1 or more counters and hasn’t revived this turn, offer to revive
	if inferno:GetCounter(INFERNO_COUNTER)>=1 and Duel.GetFlagEffect(tp,id*100+1)==0
		and Duel.IsExistingMatchingCard(s.revivefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			inferno:RemoveCounter(tp,INFERNO_COUNTER,1,REASON_COST)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.revivefilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				Duel.RegisterFlagEffect(tp,id*100+1,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end

function s.revivefilter(c,e,tp)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
