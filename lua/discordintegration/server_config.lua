-- SERVER CONFIGURATION
DiscordIntegration.Config = {

    /*
        url & port of where the bot can be connected to. If you
        are running your bot on the same machine, leave this to localhost.
        Port must match the configured port on the bot's end.
    */
    url = "localhost",
    port = 2052,

    /*
        Set to true if the connection should be made over SSL.
        
        This is only really necessary if you're connecting to
        the bot remotely. If both the server and the bot are
        running on the same machine, this is not necessary.

        SSL has to be set up properly on the bot's end!
    */
    secure  = false,

    /*
        Set to true if the certificate should be verified by a CA.
        Leave this to false for a self signed certificate.
        (Which is what you'll usually want)
    */
    verifyCertificate = false,

    /*
        Configure your authToken here. This must match with
        (one of) the allowed tokens set on the Bot.

        **This cannot be left empty and must be configured.**
    */
    authToken = "M0NTY3ODkwIiwib",
}