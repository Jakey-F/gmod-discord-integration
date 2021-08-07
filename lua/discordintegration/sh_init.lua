-- lua/discordintegration/sh_init.lua
AddCSLuaFile();

DiscordIntegration = {
    Message = function(...) 
        MsgC(
            Color(0, 178, 255), "[DiscordIntegration] ",
            Color(255, 255, 255), unpack({...})
        ) -- Separate statement because otherwhise it'll cut off the unpack() arguments
        Msg("\n")
    end,
    Error = function(...)
        MsgC(
            Color(0, 178, 255), "[DiscordIntegration ",
            Color(255, 0, 0), "ERROR",
            Color(0, 178, 255), "] ",
            Color(255, 255, 255), unpack({...})
        ) -- See Message
        Msg("\n")
    end
};

if SERVER then

    /*
        Discord-Integration **needs** GWSockets to connect to our Discord Bot.
        Without it (or the Bot, in that regard...), this addon becomes useless.
       
        Yes, I could just use a Lua library, or make calls directly to the API,
        but no, I'm not doing that. A bot is just nicer in general imo.
    */
    require("gwsockets")
    if not istable(GWSockets) then
        SetGlobalBool("discord-integration.GWSockets", false)
        return DiscordIntegration.Error("GWSockets not found! Discord-Integration cannot work without it!");
    else -- global bools to tell the client if they gotta load up or not
        SetGlobalBool("discord-integration.GWSockets", true)
        DiscordIntegration.Message("GWSockets found, continuing Discord-Integration Init...");
    end

    include("discordintegration/server_config.lua")

    include("discordintegration/server/websocket.lua")

    AddCSLuaFile("discordintegration/DiscordMessage.lua")
    include("discordintegration/DiscordMessage.lua")

elseif CLIENT then

    local function load()
        -- If the server isn't set up, why continue on the client?
        if not GetGlobalBool("discord-integration.GWSockets", false) then
            return DiscordIntegration.Error("Server reported GWSockets missing. Aborting!");
        else
            DiscordIntegration.Message("Loading Discord-Integration...")
        end

        include("discordintegration/DiscordMessage.lua")
    end
    -- GetGlobalBool won't work before InitPostEntity
    hook.Add("InitPostEntity", "discord-integration.InitPostEntity", load)

    // *** DEBUG *** //
    Msg("Debug Call : ")load()
    // *** DEBUG *** //
end