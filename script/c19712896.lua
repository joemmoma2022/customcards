--Masked HERO - Beetle
local s,id=GetID()
function s.initial_effect(c)
	-- Must be Special Summoned with "Mask Change"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,se,sp,st)
		return se and se:GetHandler():IsCode(21143940) -- "Mask Change"
	end)
	c:RegisterEffect(e0)

	-- On Summon: Add "Masked Technique - Clock-Up!" from outside the duel (once per duel)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)

	-- Negate and destroy "Super Speed" cards activated by opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

-- Add "Masked Technique - Clock-Up!"
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local token=Duel.CreateToken(tp,19712902)
	Duel.SendtoHand(token,nil,REASON_RULE)
	Duel.ConfirmCards(1-tp,token)
end

-- If opponent activates a "Super Speed" card, negate and destroy it
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep~=tp and rc and rc:IsSetCard(0x9567) and Duel.IsChainDisablable(ev) then
		Duel.NegateActivation(ev)
		if rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end