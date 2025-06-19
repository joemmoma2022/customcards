local s,id=GetID()
local ARC_MAG_ID=31924889
local ARC_WIZ_ID=19712843

function s.initial_effect(c)
	-- Activate: Tribute a Spellcaster to Special Summon Arcanite Magician
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- GY effect: Banish to Synchro Summon Arcanite Wizard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
end

function s.spfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsReleasable() and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function s.exfilter(c,e,tp)
	return c:IsCode(ARC_MAG_ID) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil)<=0 then return end
	local sc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- Disable its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
	end
end

function s.arcfilter(c)
	return c:IsFaceup() and c:IsCode(ARC_MAG_ID)
end
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave()
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.arcfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.synfilter(c,e,tp)
	return c:IsCode(ARC_WIZ_ID) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local arc=Duel.SelectMatchingCard(tp,s.arcfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not arc then return end

	-- Select Spellcaster(s) from hand or Deck
	local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end

	-- Total levels check (Level 6 Arcanite Magician + Level 2 = 8 assumed for Wizard)
	local matg=Group.FromCards(arc,g:GetFirst())
	for tc in matg:Iter() do
		Duel.SendtoGrave(tc,REASON_MATERIAL+REASON_SYNCHRO)
	end

	local syncard=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if syncard then
		syncard:SetMaterial(matg)
		Duel.SpecialSummon(syncard,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		syncard:CompleteProcedure()
	end
end
