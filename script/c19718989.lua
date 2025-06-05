--Jurrac Remixed Evolution (Start-of-Duel Optimized)
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

	-- Create tokens immediately
	local revice=Duel.CreateToken(tp,19712854)
	local revi=Duel.CreateToken(tp,19712852)
	local vice=Duel.CreateToken(tp,19712853)

	-- Add "Jurrac Remixed Rex Revice" to Extra Deck
	if revice then
		local g1=Group.CreateGroup()
		g1:AddCard(revice)
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Add Revi + Vice to hand
	local g2=Group.FromCards(revi, vice)
	Duel.SendtoHand(g2,nil,REASON_RULE)

	-- Register Ignition effect: Once per Duel, treat 1 face-up monster you control as Dinosaur
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.racetg)
	e2:SetOperation(s.raceop)
	Duel.RegisterEffect(e2,tp)
end

-- Target a face-up monster you control
function s.racefilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_DINOSAUR)
end
function s.racetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.racefilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.racefilter,tp,LOCATION_MZONE,0,1,1,nil)
end

-- Add Dinosaur race to selected monster
function s.raceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_CARD,tp,id)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_RACE)
		e1:SetValue(RACE_DINOSAUR)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
