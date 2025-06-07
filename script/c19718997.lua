-- Gem-Knight Inferno Crystal Skill
local s,id=GetID()

function s.initial_effect(c)
    -- Add Skill procedure
    aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
    -- Startup effect: flip this skill face-up at duel start
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetOperation(s.startupop)
    c:RegisterEffect(e1)
end

-- Flip this card face-up at the start of the duel
function s.startupop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
end

-- Flip condition: can activate if Fusion Summon of Inferno Crystal possible substituting materials from hand/field
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    if not aux.CanActivateSkill(tp) then return false end
    if Duel.GetFlagEffect(tp,id)>0 then return false end

    local params = {
        fusfilter = s.fusfilter,
        matfilter = s.matfilter,
        extrafil = function(e,tp,mg)
            return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        end,
        extratg = nil,
        stage2 = function(e,tc,tp,sg)
            if tc then
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
        end,
    }
    return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end

-- Flip operation: perform the Fusion Summon substituting materials
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)
    Duel.RegisterFlagEffect(tp,id,0,0,0)

    local params = {
        fusfilter = s.fusfilter,
        matfilter = s.matfilter,
        extrafil = function(e,tp,mg)
            return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        end,
        extratg = nil,
        stage2 = function(e,tc,tp,sg)
            if tc then
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
        end,
    }
    Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
    Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end

-- Fusion monster filter: must be Gem-Knight Inferno Crystal
function s.fusfilter(c)
    return c:IsCode(19712840)
end

-- Fusion materials: Gem-Knight Crystal or Pyro monster, must be fusion material
function s.matfilter(c)
    return (c:IsCode(76908448) -- Gem-Knight Crystal
        or c:IsRace(RACE_PYRO)) and c:IsCanBeFusionMaterial()
end
