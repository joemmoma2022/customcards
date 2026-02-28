-- Assault Lion Skill
local s,id=GetID()

local LION_ID=511002442
local ACTION_ID=200412334

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

	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Special Summon Assault Lion from hand or deck
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.GetMatchingGroup(function(tc)
			return tc:IsCode(LION_ID)
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
		end,tp,LOCATION_HAND+LOCATION_DECK,0,nil)

		if #g>0 then
			Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end

	-- Place "Assault Lion's Actions" from outside the Duel
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local tracker=Duel.CreateToken(tp,ACTION_ID)
		if tracker then
			Duel.MoveToField(tracker,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end

	-- Resummon Assault Lion if it leaves the field
	local e_resum=Effect.CreateEffect(c)
	e_resum:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e_resum:SetCode(EVENT_LEAVE_FIELD)
	e_resum:SetRange(0x5f)
	e_resum:SetOperation(s.check_leave)
	e_resum:SetLabel(tp)
	Duel.RegisterEffect(e_resum,tp)
end

function s.check_leave(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:IsPreviousControler(p)
			and tc:IsPreviousLocation(LOCATION_ONFIELD)
			and tc:IsCode(LION_ID) then

			if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
				local g=Duel.GetMatchingGroup(function(c)
					return c:IsCode(LION_ID)
						and c:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
				end,p,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)

				if #g>0 then
					Duel.Hint(HINT_CARD,0,id)
					Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
				end
			end
		end
	end
end