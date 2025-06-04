--Jurrac Token
local s,id=GetID()
function s.initial_effect(c)
	--No special effects; this is a simple token
	c:EnableReviveLimit()
end
