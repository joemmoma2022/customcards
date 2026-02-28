local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.lionfilter(c)
	return c:IsFaceup() and c:IsCode(511002442)
end

function s.posfilter(c)
	return c:IsCanChangePosition() and not c:IsPosition(POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lionfilter(chkc))
			or (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc))
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.lionfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	end

	-- Target Assault Lion
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lionfilter,tp,LOCATION_MZONE,0,1,1,nil)

	-- Target opponent monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,-250)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<2 then return end

	local lion=g:Filter(s.lionfilter,nil):GetFirst()
	local tc=g:Filter(Card.IsControler,nil,1-tp):GetFirst()

	if lion and lion:IsRelateToEffect(e) and lion:IsFaceup() then
		-- Apply -250 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-250)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		lion:RegisterEffect(e1)

		-- If ATK successfully changed
		if lion:GetAttack() < lion:GetBaseAttack() then
			if tc and tc:IsRelateToEffect(e) then
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			end
		end
	end
end