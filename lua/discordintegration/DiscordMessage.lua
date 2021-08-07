--[[
    -- Too Little Happens in the Different File --

    Directly called by OPCODE.MESSAGE with `data`
    being a Discord Message Object
]]

local function intToRGB(int)
    if not isnumber(int) then return color_white end
    local r = bit.band(bit.rshift(int, 16), 255)
    local g = bit.band(bit.rshift(int, 8), 255)
    local b = bit.band(int, 255)
    return Color(r, g, b)
end

local function RGBToInt(rgb)
    return 0
end

function DiscordIntegration:DiscordMessage( data )
    local message   = data.message
    local author    = data.author
    local member    = data.member
    local channel   = data.channel
    local guild     = data.guild

    if CLIENT then

        chat.AddText(
            Color(0, 178, 255), "[Discord] ",
            member.displayColor != 0 and intToRGB(member.displayColor) or color_white, member.nickname || author.username,
            color_white, ": ", message.content
        )
        

    elseif SERVER then

        net.Start("discord-integration.Message")
            net.WriteTable(data)
        net.Broadcast()

        MsgC(
            Color(0, 178, 255), "[Discord] ", color_white,
            author.username , "#", author.discriminator, " (", author.id, "): ", message.content,
            "\n"
        )

    end
end

if CLIENT then
    net.Receive("discord-integration.Message", function()
        local data = net.ReadTable()
        hook.Call("DiscordMessage", DiscordIntegration, data)
    end)
elseif SERVER then
    util.AddNetworkString("discord-integration.Message")
end