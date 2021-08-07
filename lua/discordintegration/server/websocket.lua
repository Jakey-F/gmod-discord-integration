--[[

    Create a nice little interface to handle the connection,
    sending & receiving data to & from the Discord Bot.

    SOCKET = GWSockets.createWebSocket
    socket = hook argument

]]

local config = DiscordIntegration.Config

local SOCKET = GWSockets.createWebSocket(
    ("%s://%s%s"):format(
        (
            config.secure and "wss" or "ws"         -- PROTOCOL
        ), -- expression   ?    true   :   false
        config.url,                                 -- URL
        config.port and (":" .. config.port) || ""  -- PORT
    ),
    config.verifyCertificate
)

DiscordIntegration.ws = {
    socket = SOCKET,
    protocol = config.secure and "wss" or "ws",
    url = config.url,
    port = config.port,
    connected = false,
    OPCODES = {

        /*
            HELLO is a response received from the Bot.
            It indicates it accepted our connection.
        */
        HELLO = 0,

        /*
            MESSAGE is pretty much what it says it is.
        */
        MESSAGE = 1,
    }
}

/*
    An authToken must be specified that will be sent
    as initial request to the Bot. It will accept or
    reject the connection based on this. Set this to
    a passphrase (best randomly generated & long), and
    configure it on the Bot and in the Config file
*/
SOCKET:setHeader("Authorization", config.authToken)

-- According to GWSockets' docs, SOCKET:isConnected() is not reliable?
function SOCKET:onConnected()
    DiscordIntegration.ws.connected = true
    hook.Call("WebSocketConnected", DiscordIntegration, self)
end

/*
    Set up a listener to 
    convert JSON payload into a table. If this isn't
    valid JSON, we don't do anything. Too bad.
    If we have valid JSON, convert it to a table and call
    WebSocketMessage with the payload table and raw string.
    
    Our default implementation for WebSocketMessage will handle the rest.
*/
function SOCKET:onMessage( message )
    hook.Call("WebSocketRaw", DiscordIntegration, self, message) -- always called for raw data
    local payload = util.JSONToTable(message)
    if not istable(payload) then return end
    hook.Call("WebSocketMessage", DiscordIntegration, self, payload, message)
end

function DiscordIntegration:ConnectionAccepted(socket)
    self.Message("Server responded with HELLO. Connection Established!")
end
function DiscordIntegration:WebSocketMessage(socket, data, dataStr)
    if not istable(data) then return false, "EXPECTED TABLE AS 2ND ARGUMENT - GOT " .. type(data) end
    local OP = data.OPCODE
    if data.error then    
        self.Error(
            ("Bot Error%s: %s"):format(
                data.errCode and " ("..data.errCode..")" or "",
                data.errMessage
            )
        )
    elseif (OP == self.ws.OPCODES.HELLO) then
        hook.Call("ConnectionAccepted", self, socket)
    elseif (OP == self.ws.OPCODES.MESSAGE) then
        hook.Call("DiscordMessage", self, data.discordMessage)
    end
end

function DiscordIntegration:WebSocketDisconnected(socket)
    self.Message("WebSocket Disconnected.")
end
function SOCKET:onDisconnected()
    DiscordIntegration.ws.connected = false
    hook.Call("WebSocketDisconnected", DiscordIntegration, self)
end
function SOCKET:onError( message )
    --onDisconnect gets called after
    hook.Call("WebSocketError", DiscordIntegration, self, message)
end

function DiscordIntegration:GetWebSocket()
    return self.ws.socket
end
function DiscordIntegration:IsConnected()
    return self.ws.connected
end
function DiscordIntegration:Connect(force)
    if self:IsConnected() && not force then return false end
    SOCKET:open()
end
function DiscordIntegration:Disconnect(now)
    if now then
        SOCKET:closeNow()
    else
        SOCKET:close()
    end
end