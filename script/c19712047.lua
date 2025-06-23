local s,id=GetID()
local SLASH_ARC=0x9801

function s.initial_effect(c)
    -- Add 1 "Slash" card from Deck to hand; treated as Quick-Play Spell until sent to Graveyard
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    return c:IsSetCard(SLASH_ARC) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
            Duel.ConfirmCards(1-tp,tc)
            -- Apply global effect to treat card as Quick-Play Spell until it hits Graveyard
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_QUICKPLAY+TYPE_SPELL)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)

            -- Apply a continuous effect to remove this type change when sent to GY
            local ge=Effect.CreateEffect(e:GetHandler())
            ge:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
            ge:SetCode(EVENT_TO_GRAVE)
            ge:SetOperation(function(e2,tp2,eg2,ep2,ev2,re2,r,rp2)
                e2:GetHandler():ResetEffect(EFFECT_CHANGE_TYPE,RESET_CODE)
                e2:Reset()
            end)
            ge:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(ge)
        end
    end
end
