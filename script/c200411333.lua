-- Millennium Golem Skill
local s,id=GetID()

local GOLEM=47986555
local ACTION_ID=200412333

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

	-- Halve all damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)
end

function s.damval(e,re,val,r,rp,rc)
	return math.ceil(val/2)
end

function s.startup_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	-- Special Summon Millennium Golem from hand or deck
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.GetMatchingGroup(function(tc)
			return tc:IsCode(GOLEM) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
		end,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		if #g>0 then
			Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end

	-- Place "Stone Golem's Actions" from outside the duel
	local tracker=Duel.CreateToken(tp,ACTION_ID)
	if tracker and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(tracker,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end

	-- Resummon Millennium Golem if it leaves the field (any zone)
	local e_resum=Effect.CreateEffect(c)
	e_resum:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e_resum:SetCode(EVENT_LEAVE_FIELD)
	e_resum:SetOperation(s.check_leave)
	e_resum:SetLabel(tp)
	Duel.RegisterEffect(e_resum,tp)
end

function s.check_leave(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:IsPreviousControler(p)
			and tc:IsPreviousLocation(LOCATION_ONFIELD)
			and tc:IsCode(GOLEM) then

			if Duel.GetLocationCount(p,LOCATION_MZONE)>0 then
				local g=Duel.GetMatchingGroup(function(c)
					return c:IsCode(GOLEM) and c:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
				end,p,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
				if #g>0 then
					Duel.Hint(HINT_CARD,0,id)
					Duel.SpecialSummon(g:GetFirst(),0,p,p,false,false,POS_FACEUP_ATTACK)
				end
			end
		end
	end
end
