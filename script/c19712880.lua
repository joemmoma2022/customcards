-- Malevolent Takeover
-- Custom Spell Card
-- Card ID placeholder: 19720002 (replace with actual ID)
local s,id=GetID()
local MALEVOLENT_SIN_ID=80796456
function s.initial_effect(c)
	-- Activate only if you control no monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- You control no monsters
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- Filter: Face-up, not summoned from Extra Deck, opponent's control, changeable control
function s.filter(c,e,tp)
	return c:IsFaceup()
		and c:GetSummonLocation()~=LOCATION_EXTRA
		and c:IsControler(1-tp)
		and c:IsAbleToChangeControler()
		and c:IsCanBeEffectTarget(e)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e,tp)
		return #g>=2 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,1,nil,MALEVOLENT_SIN_ID)
	end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,2,2,nil,e,tp)
	Duel.SetTargetCard(g)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end

	local mg=Group.CreateGroup()
	for tc in aux.Next(g) do
		if not tc:IsRelateToEffect(e) or Duel.GetControl(tc,tp)==0 then return end

		-- Change Race and Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_INSECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(4)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)

		mg:AddCard(tc)
	end

	if #mg<2 then return end

	-- Xyz Summon Number 70: Malevolent Sin
	if Duel.GetLocationCountFromEx(tp,tp,mg)>0 then
		local xyz=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_EXTRA,0,1,1,nil,MALEVOLENT_SIN_ID):GetFirst()
		if xyz then
			Duel.XyzSummon(tp,xyz,mg)
		end
	end
end
