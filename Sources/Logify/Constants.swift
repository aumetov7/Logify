enum LogifyConstants {
    /// Подсистема по умолчанию, если Bundle.main.bundleIdentifier недоступен.
    static let defaultSubsystem = "DefaultSubsystem"
    /// Префикс логгера, который будет отображаться в каждом сообщении.
    static let logPrefix = "Logify"
    /// Префикс для логирования запросов.
    static let requestPrefix = "➡️ [REQUEST]"
    /// Префикс для логирования ответов.
    static let responsePrefix = "⬅️ [RESPONSE]"
    /// Префикс для отображения HTTP заголовков.
    static let headersPrefix = "Headers:"
    /// Префикс для отображения тела запроса.
    static let bodyPrefix = "Body:"
    /// Префикс для отображения JSON ответа.
    static let responseJSONPrefix = "Response JSON:"
}
