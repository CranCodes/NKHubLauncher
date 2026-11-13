local teleportScript = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CranCodes/nkhubs/refs/heads/main/PSAC.lua"))()
]]

if queue_on_teleport then
    queue_on_teleport(teleportScript)
elseif queueonteleport then
    queueonteleport(teleportScript)
else
    warn("Your executor doesn't support queue_on_teleport")
end

-- Execute your script in the current server too
loadstring(game:HttpGet("https://raw.githubusercontent.com/CranCodes/nkhubs/refs/heads/main/PSAC.lua"))()
