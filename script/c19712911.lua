local s,id=GetID()
local CARD_UMI=22702055
local BIG_UMI=19712909

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
s.listed_names={CARD_UMI,BIG_UMI} -- Umi and Big Umi

-- You must control a Fish or Sea Serpent monster
function s.cfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_FISH) or c:IsRace(RACE_SEASERPENT))
end

-- Condition: Opponent declares attack and you control a Fish or Sea Serpent
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Cost: Destroy 1 "Umi" or "Big Umi" you control
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.umidestroyfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.umidestroyfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Destroy(g,REASON_COST)
end

-- Filter for "Umi" or "Big Umi" you control to destroy
function s.umidestroyfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_UMI) or c:IsCode(BIG_UMI)) and c:IsDestructable()
end

-- Target: At least one opponent's face-up monster and player can draw 1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsPlayerCanDraw(tp,1) 
	end
end

-- Operation: Destroy highest ATK opponent monster, draw 1, and if drawn card is Umi/Big Umi, deal 500 damage, else discard it
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end

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
			if dc:IsCode(CARD_UMI) or dc:IsCode(BIG_UMI) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			else
				Duel.SendtoGrave(dc,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end
