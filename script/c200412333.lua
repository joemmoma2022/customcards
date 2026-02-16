local s,id=GetID()
local COUNTER_BOSS_ACTION=0x2319

function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BOSS_ACTION)

	-- Unaffected by other card effects
	local e_immune=Effect.CreateEffect(c)
	e_immune:SetType(EFFECT_TYPE_SINGLE)
	e_immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e_immune:SetRange(LOCATION_SZONE)
	e_immune:SetCode(EFFECT_IMMUNE_EFFECT)
	e_immune:SetValue(s.efilter)
	c:RegisterEffect(e_immune)

	-- Halve ALL damage you take (battle + effect)
	local e_dmg=Effect.CreateEffect(c)
	e_dmg:SetType(EFFECT_TYPE_FIELD)
	e_dmg:SetCode(EFFECT_CHANGE_DAMAGE)
	e_dmg:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_dmg:SetRange(LOCATION_SZONE)
	e_dmg:SetTargetRange(1,0)
	e_dmg:SetValue(s.damval)
	c:RegisterEffect(e_dmg)

	-- Skip all your Draw Phases
	local e_skip=Effect.CreateEffect(c)
	e_skip:SetType(EFFECT_TYPE_FIELD)
	e_skip:SetCode(EFFECT_SKIP_DP)
	e_skip:SetRange(LOCATION_SZONE)
	e_skip:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_skip:SetTargetRange(1,0)
	c:RegisterEffect(e_skip)

	-- Your monsters cannot be destroyed by battle
	local e_protect=Effect.CreateEffect(c)
	e_protect:SetType(EFFECT_TYPE_FIELD)
	e_protect:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e_protect:SetRange(LOCATION_SZONE)
	e_protect:SetTargetRange(LOCATION_MZONE,0)
	e_protect:SetValue(1)
	c:RegisterEffect(e_protect)

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
	e_search:SetDescription(aux.Stringid(id,0))
	e_search:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e_search:SetType(EFFECT_TYPE_IGNITION)
	e_search:SetRange(LOCATION_SZONE)
	e_search:SetCountLimit(1)
	e_search:SetTarget(s.thtg)
	e_search:SetOperation(s.thop)
	c:RegisterEffect(e_search)

	-- Opponent's End Phase: shuffle all GY cards into Deck if Deck is empty
	local e_gyeffect=Effect.CreateEffect(c)
	e_gyeffect:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e_gyeffect:SetCode(EVENT_PHASE+PHASE_END)
	e_gyeffect:SetRange(LOCATION_SZONE)
	e_gyeffect:SetCondition(s.shufflegy_con)
	e_gyeffect:SetOperation(s.shufflegy_op)
	c:RegisterEffect(e_gyeffect)

	-- Each End Phase: monsters lose 500 ATK
	local e_end=Effect.CreateEffect(c)
	e_end:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e_end:SetCode(EVENT_PHASE+PHASE_END)
	e_end:SetRange(LOCATION_SZONE)
	e_end:SetCountLimit(1)
	e_end:SetOperation(s.endphase_op)
	c:RegisterEffect(e_end)
end


function s.damval(e,re,dam,r,rp,rc)
	if dam then
		return dam/2
	end
end

-- Spell immunity filter
function s.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end

-- Shuffle hand into Deck
function s.handshuffle_op(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end

-- Opponent's End Phase condition
function s.shufflegy_con(e,tp)
	return Duel.GetTurnPlayer()==1-tp
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0
		and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>0
end

-- Shuffle ALL GY cards into Deck
function s.shufflegy_op(e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end

-- End Phase ATK loss
function s.endphase_op(e,tp)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- Search target
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
