-- Noble Justice and Vengeance
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

	-- Create cards from outside the Duel
	local risen=Duel.CreateToken(tp,19712844)
	local justice=Duel.CreateToken(tp,19712845)

	-- Add Risen to Extra Deck
	if risen then
		local g=Group.CreateGroup()
		g:AddCard(risen)
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_RULE)
	end

	-- Add Justice to hand
	if justice then
		Duel.SendtoHand(justice,nil,REASON_RULE)
	end

	-- Halve battle damage if Risen is not controlled
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_ALL)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(function(e)
		return not Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,19712844)
	end)
	e2:SetValue(function(e,re,dam,r,rp,rc)
		if bit.band(r,REASON_BATTLE)~=0 then
			return math.floor(dam/2)
		end
		return dam
	end)
	Duel.RegisterEffect(e2,tp)

	-- Double battle damage if Risen is battling
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_ALL)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetCondition(function(e)
		local bc1=Duel.GetBattleMonster(0)
		local bc2=Duel.GetBattleMonster(1)
		return (bc1 and bc1:IsCode(19712844)) or (bc2 and bc2:IsCode(19712844))
	end)
	e3:SetValue(function(e,re,dam,r,rp,rc)
		if bit.band(r,REASON_BATTLE)~=0 then
			return dam*2
		end
		return dam
	end)
	Duel.RegisterEffect(e3,tp)

	-- Risen's summon effect: wipe field + damage + skip BP
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.risen_xyz_trigger)
	Duel.RegisterEffect(e4,tp)
end

function s.risen_xyz_trigger(e,tp,eg,ep,ev,re,r,rp)
	for sc in aux.Next(eg) do
		if sc:IsCode(19712844) and sc:IsSummonType(SUMMON_TYPE_XYZ) then
			Duel.Hint(HINT_CARD,tp,id)

			-- Destroy all other cards
			local g=Duel.GetMatchingGroup(aux.NOT(Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,19712844)
			local ct=Duel.Destroy(g,REASON_EFFECT)

			-- Deal 100 damage to both players for each card destroyed
			if ct > 0 then
				Duel.Damage(tp,ct*100,REASON_EFFECT)
				Duel.Damage(1-tp,ct*100,REASON_EFFECT)
			end

			-- Prevent Battle Phase this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
