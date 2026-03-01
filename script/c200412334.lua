local s,id=GetID()
local FEAST_ID=20411336
local LION_ID=511002442

function s.initial_effect(c)

	-- Unaffected by other card effects
	local e_immune=Effect.CreateEffect(c)
	e_immune:SetType(EFFECT_TYPE_SINGLE)
	e_immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e_immune:SetRange(LOCATION_SZONE)
	e_immune:SetCode(EFFECT_IMMUNE_EFFECT)
	e_immune:SetValue(s.efilter)
	c:RegisterEffect(e_immune)

	-- Skip all your Draw Phases
	local e_skip=Effect.CreateEffect(c)
	e_skip:SetType(EFFECT_TYPE_FIELD)
	e_skip:SetCode(EFFECT_SKIP_DP)
	e_skip:SetRange(LOCATION_SZONE)
	e_skip:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_skip:SetTargetRange(1,0)
	c:RegisterEffect(e_skip)

	-- During your Standby Phase: shuffle your hand into the Deck
	local e_shufflehand=Effect.CreateEffect(c)
	e_shufflehand:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e_shufflehand:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e_shufflehand:SetRange(LOCATION_SZONE)
	e_shufflehand:SetCountLimit(1)
	e_shufflehand:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e_shufflehand:SetOperation(s.handshuffle_op)
	c:RegisterEffect(e_shufflehand)

	-- Once per turn: add 1 card from Deck to hand
	local e_search=Effect.CreateEffect(c)
	e_search:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e_search:SetType(EFFECT_TYPE_IGNITION)
	e_search:SetRange(LOCATION_SZONE)
	e_search:SetCountLimit(1)
	e_search:SetTarget(s.thtg)
	e_search:SetOperation(s.thop)
	c:RegisterEffect(e_search)

	-- After attack resolution: 1 monster you control loses 250 ATK
	local e_attack=Effect.CreateEffect(c)
	e_attack:SetCategory(CATEGORY_ATKCHANGE)
	e_attack:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e_attack:SetCode(EVENT_DAMAGE_STEP_END)
	e_attack:SetRange(LOCATION_SZONE)
	e_attack:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e_attack:SetCountLimit(1)
	e_attack:SetCondition(s.atk_con)
	e_attack:SetTarget(s.atk_tg)
	e_attack:SetOperation(s.atk_op)
	c:RegisterEffect(e_attack)

	-- Once per turn: If an "Assault Lion" you control has less than 1000 ATK:
	-- Add 1 "Assault Lion's Feast" from outside the Duel to your hand
	local e_feast=Effect.CreateEffect(c)
	e_feast:SetType(EFFECT_TYPE_IGNITION)
	e_feast:SetRange(LOCATION_SZONE)
	e_feast:SetCountLimit(1,id)
	e_feast:SetCondition(s.feast_con)
	e_feast:SetOperation(s.feast_op)
	c:RegisterEffect(e_feast)

	-- Your monsters cannot be destroyed by battle
	local e_protect=Effect.CreateEffect(c)
	e_protect:SetType(EFFECT_TYPE_FIELD)
	e_protect:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e_protect:SetRange(LOCATION_SZONE)
	e_protect:SetTargetRange(LOCATION_MZONE,0)
	e_protect:SetValue(1)
	c:RegisterEffect(e_protect)
	
	-- During opponent's End Phase: shuffle non-monsters from GY if Deck is empty
    local e_gyeffect=Effect.CreateEffect(c)
    e_gyeffect:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e_gyeffect:SetCode(EVENT_PHASE+PHASE_END)
    e_gyeffect:SetRange(LOCATION_SZONE)
    e_gyeffect:SetCondition(s.shufflegy_con)
    e_gyeffect:SetOperation(s.shufflegy_op)
    c:RegisterEffect(e_gyeffect)
end

function s.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end

function s.handshuffle_op(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- After battle resolution condition
function s.atk_con(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a and a:IsControler(tp) and a:IsRelateToBattle()
end

-- Target 1 monster you control
function s.atk_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,-250)
end

-- Apply -250 ATK
function s.atk_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-250)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e1)
	end
end

-- Opponent's End Phase condition
function s.shufflegy_con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0
        and Duel.IsExistingMatchingCard(s.nonmonsterfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- Shuffle non-monster GY cards into Deck
function s.shufflegy_op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.nonmonsterfilter,tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end

function s.nonmonsterfilter(c)
    return not c:IsType(TYPE_MONSTER)
end

-- Feast condition: Assault Lion with less than 1000 ATK
function s.feast_con(e,tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(LION_ID)
			and c:GetAttack()<1000
	end,tp,LOCATION_MZONE,0,1,nil)
end

function s.feast_op(e,tp)
	local token=Duel.CreateToken(tp,FEAST_ID)
	if token then
		Duel.SendtoHand(token,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,token)
	end

end
