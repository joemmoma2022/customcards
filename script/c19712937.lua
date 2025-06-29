--プレイング・マンティス
--Praying Mantis
local s,id=GetID()
local TOKEN_BABY_MANTIS=19712975

function s.initial_effect(c)
	-- Once per turn: When opponent's monster declares an attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Special Summon Baby Mantis Token during your Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Banish this card from GY to Special Summon 1 Baby Mantis Token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

-- ATK declare condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end

-- Cost: send 1 card from your S/T Zone to GY
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Return attacker to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.GetAttacker(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() then
		Duel.SendtoHand(at,nil,REASON_EFFECT)
	end
end

-- Standby Phase condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
end

-- Shared token summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

-- Shared token summon op + destroy during *next* End Phase
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then return end

	local token=Duel.CreateToken(tp,TOKEN_BABY_MANTIS)
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
		local turn_count=Duel.GetTurnCount()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(turn_count)
		e1:SetLabelObject(token)
		e1:SetCondition(s.descon_next_turn)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		Duel.RegisterEffect(e1,tp)
	end
end

-- Check if it’s the next turn’s End Phase
function s.descon_next_turn(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField() and Duel.GetTurnCount()>e:GetLabel()
end

-- Destroy token
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
