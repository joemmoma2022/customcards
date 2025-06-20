local s,id=GetID()
function s.initial_effect(c)
	-- Activate on opponent's attack declaration
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_DAMAGE+CATEGORY_TODECK+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI,19712909} -- Umi and Big Umi

-- You must control a Fish or Sea Serpent monster
function s.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_FISH) or c:IsRace(RACE_SEASERPENT))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Shuffle 1 Spell/Trap you control
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Get opponent's monsters
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

	-- Find the highest ATK monster(s)
	local max_atk=g:GetMaxGroup(Card.GetAttack)
	if #max_atk>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		max_atk=max_atk:Select(tp,1,1,nil)
	end
	local tc=max_atk:GetFirst()
	if tc and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc then
			Duel.ConfirmCards(1-tp,dc)
			if dc:IsCode(CARD_UMI) or dc:IsCode(19712909) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			else
				Duel.SendtoGrave(dc,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
