-- Abyssal Sea Dragon Skill
local s,id=GetID()

local KRAKEN_MAIN=19712934
local KRAKEN_L=19712935
local KRAKEN_R=19712936
local FIELD_ID=22702055
local TRACKER_ID=19719011

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,nil,nil)

	-- Startup operation
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startup_op)
	c:RegisterEffect(e1)
end

function s.startup_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetHandlerPlayer()

	Duel.Hint(HINT_SKILL_FLIP,p,id|(1<<32))
	Duel.Hint(HINT_CARD,p,id)

	-- Set LP to 40000
	Duel.SetLP(p,4650)

	-- Place Field Spell "Boss Field - Raging Waves"
	local existing_field=Duel.GetFieldCard(p,LOCATION_FZONE,0)
	if existing_field then
		Duel.SendtoGrave(existing_field,REASON_RULE)
	end
	local fieldcard=Duel.GetMatchingGroup(Card.IsCode,p,LOCATION_DECK,0,nil,FIELD_ID):GetFirst()
	if fieldcard then
		Duel.MoveToField(fieldcard,p,p,LOCATION_FZONE,POS_FACEUP,true)
	end

	-- Place "Boss Action Tracker" Continuous Spell from outside the duel (Skill zone)
	local tracker=Duel.CreateToken(p,TRACKER_ID)
	if Duel.GetLocationCount(p,LOCATION_SZONE)>0 and tracker then
		Duel.MoveToField(tracker,p,p,LOCATION_SZONE,POS_FACEUP,true)

		-- Apply "Infinite Cards"-like effect from Tracker
		local e_hand=Effect.CreateEffect(tracker)
		e_hand:SetType(EFFECT_TYPE_FIELD)
		e_hand:SetCode(EFFECT_HAND_LIMIT)
		e_hand:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e_hand:SetRange(LOCATION_SZONE)
		e_hand:SetTargetRange(1,0)
		e_hand:SetValue(100)
		tracker:RegisterEffect(e_hand)
	end

	-- Special Summon 1 Kraken Main
	if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
		local g=Duel.GetMatchingGroup(function(tc)
			return tc:IsCode(KRAKEN_MAIN) and tc:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
		end,p,LOCATION_DECK,0,nil)
		if #g>0 then
			Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
		end
	end

	-- Special Summon 2 Kraken L
	for i=1,2 do
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
			local g=Duel.GetMatchingGroup(function(tc)
				return tc:IsCode(KRAKEN_L) and tc:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
			end,p,LOCATION_DECK,0,nil)
			if #g>0 then
				Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
			end
		end
	end

	-- Special Summon 2 Kraken R
	for i=1,2 do
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
			local g=Duel.GetMatchingGroup(function(tc)
				return tc:IsCode(KRAKEN_R) and tc:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
			end,p,LOCATION_DECK,0,nil)
			if #g>0 then
				Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
			end
		end
	end

	-- Skip all Draw Phases for controller
	local e_skip=Effect.CreateEffect(c)
	e_skip:SetType(EFFECT_TYPE_FIELD)
	e_skip:SetCode(EFFECT_SKIP_DP)
	e_skip:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_skip:SetTargetRange(1,0)
	e_skip:SetReset(RESET_PHASE+PHASE_END,0)
	Duel.RegisterEffect(e_skip,p)

	-- Resummon Kraken [L] or [R] if they leave the field (any zone)
	local e_resum=Effect.CreateEffect(c)
	e_resum:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e_resum:SetCode(EVENT_LEAVE_FIELD)
	e_resum:SetOperation(s.check_leave)
	e_resum:SetLabel(p)
	Duel.RegisterEffect(e_resum,p)
end

function s.check_leave(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:IsPreviousControler(p)
			and tc:IsPreviousLocation(LOCATION_ONFIELD)
			and (tc:IsCode(KRAKEN_L) or tc:IsCode(KRAKEN_R)) then

			if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
				local g=Duel.GetMatchingGroup(function(c)
					return c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
				end,p,LOCATION_HAND+LOCATION_DECK,0,nil)
				if #g>0 then
					Duel.Hint(HINT_CARD,0,id)
					Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
				end
			end
		end
	end
end
