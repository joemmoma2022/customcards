-- T.G. Evolution Drive (Skill Card)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)

	-- Auto flip + card creation at Duel start
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
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32)) -- Mark skill as flipped
	Duel.Hint(HINT_CARD,tp,id)

	-- Add Red Rabbit and Blue Tank to hand
	local red=Duel.CreateToken(tp,19712856)
	local blue=Duel.CreateToken(tp,19712857)
	if red then Duel.SendtoHand(red,nil,REASON_RULE) end
	if blue then Duel.SendtoHand(blue,nil,REASON_RULE) end

	-- Add Striker RabbitTank to Extra Deck
	local xyz=Duel.CreateToken(tp,19712858)
	if xyz then
		local g=Group.CreateGroup()
		g:AddCard(xyz)
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Set up passive continuous effect
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.passiveop)
	e2:SetCountLimit(1)
	Duel.RegisterEffect(e2,tp)
end

-- Passive effects while you control "T.G. Striker RabbitTank"
function s.rabbittankfilter(c)
	return c:IsFaceup() and c:IsCode(19712858)
end

function s.passiveop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.rabbittankfilter,tp,LOCATION_MZONE,0,1,nil) then return end

	local c=e:GetHandler()

	-- Make all T.G. monsters also Beast and Machine
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		if not tc:IsRace(RACE_BEAST) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_RACE)
			e1:SetValue(RACE_BEAST)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if not tc:IsRace(RACE_MACHINE) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_RACE)
			e2:SetValue(RACE_MACHINE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end

	-- Once per turn: add Rabbit or Tank counter
	if Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local rc=Duel.SelectMatchingCard(tp,s.rabbittankfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if rc then
				local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- "Rabbit"/"Tank"
				if opt==0 then
					rc:AddCounter(0x111f,1)
				else
					rc:AddCounter(0x1120,1)
				end
			end
		end
	end

	-- Finish opponent if LP ≤2000 and both counters exist on field
	local opp_lp=Duel.GetLP(1-tp)
	if opp_lp<=2000 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		local rabbit=g:GetSum(Card.GetCounter,0x111f)
		local tank=g:GetSum(Card.GetCounter,0x1120)
		if rabbit>0 and tank>0 then
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				for tc in g:Iter() do
					tc:RemoveCounter(tp,0x111f,tc:GetCounter(0x111f),REASON_EFFECT)
					tc:RemoveCounter(tp,0x1120,tc:GetCounter(0x1120),REASON_EFFECT)
				end
				Duel.Damage(1-tp,opp_lp,REASON_EFFECT)
			end
		end
	end
end

function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
