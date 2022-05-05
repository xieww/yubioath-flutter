package com.yubico.authenticator.oath

object OathTestHelper {

    // create a TOTP credential with default or custom parameters
    // if not specified, default values for deviceId, name and issuer will use a unique value
    // which is incremented on every call to this function
    fun totp(
        deviceId: String = nextDevice(),
        name: String = nextName(),
        issuer: String? = nextIssuer(),
        touchRequired: Boolean = false,
        period: Int = 30
    ) = cred(deviceId, name, issuer, Model.OathType.TOTP, touchRequired, period)

    // create a HOTP credential with default or custom parameters
    // if not specified, default values for deviceId, name and issuer will use a unique value
    // which is incremented on every call to this function
    fun hotp(
        deviceId: String = nextDevice(),
        name: String = nextName(),
        issuer: String = nextIssuer(),
        touchRequired: Boolean = false,
        period: Int = 30
    ) = cred(deviceId, name, issuer, Model.OathType.HOTP, touchRequired, period)

    private fun cred(
        deviceId: String = nextDevice(),
        name: String = nextName(),
        issuer: String? = nextIssuer(),
        type: Model.OathType,
        touchRequired: Boolean = false,
        period: Int = 30
    ) =
        Model.Credential(
            deviceId = deviceId,
            id = """otpauth://${type.name}/${name}?secret=aabbaabbaabbaabb&issuer=${issuer}""",
            oathType = type,
            period = period,
            issuer = issuer,
            accountName = name,
            touchRequired = touchRequired
        )
    // create a Code with default or custom parameters
    fun code(
        value: String = "111111",
        from: Long = 1000,
        to: Long = 2000
    ) = Model.Code(value, from, to)

    fun emptyCredentials() = emptyMap<Model.Credential, Model.Code>()

    private var nameCounter = 0
    private fun nextName(): String {
        return "name${nameCounter++}"
    }

    private var issuerCounter = 0
    private fun nextIssuer(): String {
        return "issuer${issuerCounter++}"
    }

    private var deviceCounter = 0
    private fun nextDevice(): String {
        return "deviceId${deviceCounter++}"
    }
}