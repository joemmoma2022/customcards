-- Galaxy-Eyes Meteor Knight Skill
-- Scripted by You
local s,id=GetID()

local METEOR_KNIGHT=19712869
local METEORSTRIKE=19712870
local PHOTON_DRAGON=511003205

function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,nil,nil)

	-- Startup effect: Add cards at duel start
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)

	-- Once per duel LP protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	Duel.RegisterEffect(e2,0)

	-- Extra attack after banishing opponent's monster with Meteor Knight this turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(s.extraatkcon)
	e3:SetOperation(s.extraatkop)
	Duel.RegisterEffect(e3,0)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	Duel.Hint(HINT_SKILL_FLIP,p,id|(1<<32))
	Duel.Hint(HINT_CARD,p,id)

	-- Add Meteor Knight token face-down to Extra Deck
	local meteor_knight_token=Duel.CreateToken(p,METEOR_KNIGHT)
	Duel.SendtoDeck(meteor_knight_token,p,SEQ_DECKTOP,REASON_RULE)

	-- Add Meteorstrike to hand
	local meteorstrike_token=Duel.CreateToken(p,METEORSTRIKE)
	Duel.SendtoHand(meteorstrike_token,p,REASON_RULE)
	Duel.ConfirmCards(1-p,meteorstrike_token)

	-- Add Galaxy-Eyes Photon Dragon from Deck to hand
	local g=Duel.GetMatchingGroup(Card.IsCode,p,LOCATION_DECK,0,nil,PHOTON_DRAGON)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sel=g:Select(p,1,1,nil)
		Duel.SendtoHand(sel,p,REASON_RULE)
		Duel.ConfirmCards(1-p,sel)
	end
end

-- LP protection condition
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(ep)
	return lp-ev<=0 and ep==tp and Duel.GetFlagEffect(tp,id)==0
end

-- LP protection operation: Set LP to 1 once per duel
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,1)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	Duel.Hint(HINT_CARD,tp,id)
end

-- Check if a "Galaxy-Eyes Meteor Knight" controlled by tp banished opponent monster this turn
function s.extraatkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	for tc in aux.Next(eg) do
		-- Banished card must have been controlled by opponent
		if tc:IsPreviousControler(1-tp) then
			-- Check if a Meteor Knight controlled by tp banished it
			local reason_card=Duel.GetReasonCard(tc)
			if reason_card and reason_card:IsControler(tp) and reason_card:IsCode(METEOR_KNIGHT) then
				-- Check it is your turn (the skill owner)
				if Duel.GetTurnPlayer()==tp then
					-- Mark Meteor Knight for extra attack effect this turn
					reason_card:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
					return false -- We don't want to trigger multiple times for multiple banishes
				end
			end
		end
	end
	return false
end

-- Operation: grant extra attack to Meteor Knight(s) flagged this turn
function s.extraatkop(e,tp,eg,ep,ev,re,r,rp)
	-- This will be handled by a continuous effect that checks flagged Meteor Knights and applies extra attacks
	-- So here we just do nothing; extra attacks are given dynamically below
end

-- Effect that grants extra attack to Meteor Knights flagged this turn
local function extra_attack_filter(e,c)
	return c:GetFlagEffect(id)>0
end

local function register_extra_attack_effect(tp)
	local e=Effect.CreateEffect(nil)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(EFFECT_EXTRA_ATTACK)
	e:SetTargetRange(LOCATION_MZONE,0)
	e:SetTarget(extra_attack_filter)
	e:SetValue(1)
	e:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e,tp)
end

-- We want to register this effect once the first Meteor Knight banishes a monster
-- So let's add a global check:

if not s.global_check then
	s.global_check=true
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_REMOVE)
	ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local turn_player=Duel.GetTurnPlayer()
		for tc in aux.Next(eg) do
			if tc:IsPreviousControler(1-turn_player) then
				local reason_card=Duel.GetReasonCard(tc)
				if reason_card and reason_card:IsControler(turn_player) and reason_card:IsCode(METEOR_KNIGHT) then
					reason_card:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
					register_extra_attack_effect(turn_player)
					break
				end
			end
		end
	end)
	Duel.RegisterEffect(ge1,0)
end

return s
