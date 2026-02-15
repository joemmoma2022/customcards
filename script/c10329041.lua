local s,id=GetID()
function s.initial_effect(c)
	--Activate from hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- Create "Dummy Golem" from outside the Duel
	local token=Duel.CreateToken(tp,13532663)
	if not token then return end

	-- Special Summon face-down Defense
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
		-- Cannot be Tributed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2,true)

		-- Cannot change battle position THIS TURN
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD+RESET_PHASE+PHASE_END)
		token:RegisterEffect(e3,true)

		-- Banish face-down when it leaves the field
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(LOCATION_REMOVED)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e4,true)

		local e5=e4:Clone()
		e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		token:RegisterEffect(e5,true)
	end
	Duel.SpecialSummonComplete()

	-- Banish this card face-down after resolution
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)
	end
end
