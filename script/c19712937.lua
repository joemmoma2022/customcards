--プレイング・マンティス
--Praying Mantis
local s,id=GetID()
local TOKEN_BABY_MANTIS=19712975  -- Updated token ID

function s.initial_effect(c)
	-- Return to hand an opponent's monster that declares an attack
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

	-- Special Summon 1 "Baby Mantis Token" during your Standby Phase
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

	-- Banish itself from GY to Special Summon 1 "Baby Mantis Token"
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

-- Condition: Opponent declares an attack
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp) and at:IsOnField()
end

-- Cost: Remove 1 Baby Mantis Token you control
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,TOKEN_BABY_MANTIS) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_MZONE,0,1,1,nil,TOKEN_BABY_MANTIS)
	Duel.Release(g,REASON_COST)
end

-- Target the attacking monster to return to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local at=Duel.GetAttacker()
		return at:IsAbleToHand()
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.GetAttacker(),1,0,0)
end

-- Operation: Return attacker to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() and at:IsControler(1-tp) then
		Duel.SendtoHand(at,nil,REASON_EFFECT)
	end
end

-- Condition to special summon token during Standby Phase (your turn)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
end

-- Target for special summon token
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BABY_MANTIS,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

-- Operation: Special Summon 1 Baby Mantis Token
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local token=Duel.CreateToken(tp,TOKEN_BABY_MANTIS)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
