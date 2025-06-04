--Shooting Wolf Token
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Token properties are set by default (stats, race, attribute)
    -- Since it's a token, no special effects by default, but you can add some here if you want
end
