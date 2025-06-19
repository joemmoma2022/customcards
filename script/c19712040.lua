local s,id=GetID()
local draw_done={} -- global per duel table, tracks per player if drawn

function s.initial_effect(c)
    -- (0) At the start of the duel, place this card from Deck or Hand or banish it for both players
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_PREDRAW)
    e0:SetCountLimit(1,id+100)
    e0:SetCondition(s.fieldcon)
    e0:SetOperation(s.fieldop)
    Duel.RegisterEffect(e0,0)

    -- (1) Activate normally
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- (2) Draw 3 during Draw Phase
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DRAW_COUNT)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(1,0)
    e2:SetValue(3)
    c:RegisterEffect(e2)

    -- (3) Cannot be destroyed by card effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- (4) Cannot be targeted by card effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)

    -- (5) Cannot be sent to GY by card effects
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CANNOT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- (6) If drawing with no Deck, recycle GY
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_PREDRAW)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCondition(s.shufflecon)
    e6:SetOperation(s.shuffleop)
    c:RegisterEffect(e6)
end

function s.fieldcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==1
end

function s.fieldop(e,tp,eg,ep,ev,re,r,rp)
    draw_done[0]=false
    draw_done[1]=false

    for p=0,1 do
        local fzone=Duel.GetFieldCard(p,LOCATION_FZONE,0)
        local handgroup=Duel.GetMatchingGroup(s.selfcheck,p,LOCATION_HAND,0,nil,p)
        local deckgroup=Duel.GetMatchingGroup(s.selfcheck,p,LOCATION_DECK,0,nil,p)

        if fzone==nil then
            if #handgroup>0 then
                local tc=handgroup:GetFirst()
                Duel.MoveToField(tc,p,p,LOCATION_FZONE,POS_FACEUP,true)
                Duel.Draw(p,1,REASON_EFFECT)
                draw_done[p]=true
                -- Banish other copies except tc from hand
                local banish_hand=Duel.GetMatchingGroup(s.selfcheck,p,LOCATION_HAND,0,tc,p)
                if #banish_hand>0 then Duel.Remove(banish_hand,POS_FACEUP,REASON_RULE) end
                -- Banish copies in deck
                local banish_deck=Duel.GetMatchingGroup(s.selfcheck,p,LOCATION_DECK,0,nil,p)
                if #banish_deck>0 then Duel.Remove(banish_deck,POS_FACEUP,REASON_RULE) end
            elseif #deckgroup>0 then
                local tc=deckgroup:GetFirst()
                Duel.MoveToField(tc,p,p,LOCATION_FZONE,POS_FACEUP,true)
                -- Banish all copies in hand
                if #handgroup>0 then Duel.Remove(handgroup,POS_FACEUP,REASON_RULE) end
                -- Banish other copies in deck except tc
                local banish_deck=Duel.GetMatchingGroup(s.selfcheck,p,LOCATION_DECK,0,tc,p)
                if #banish_deck>0 then Duel.Remove(banish_deck,POS_FACEUP,REASON_RULE) end
            end
        else
            -- Field zone occupied, banish all copies from hand and deck
            if #handgroup>0 then 
                Duel.Remove(handgroup,POS_FACEUP,REASON_RULE)
                if not draw_done[p] then
                    Duel.Draw(p,1,REASON_EFFECT)
                    draw_done[p]=true
                end
            end
            if #deckgroup>0 then Duel.Remove(deckgroup,POS_FACEUP,REASON_RULE) end
        end
    end
end

function s.selfcheck(c,tp)
    return c:IsCode(id)
end

function s.shufflecon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 and Duel.GetDrawCount(tp)>0
end

function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
    end
end
