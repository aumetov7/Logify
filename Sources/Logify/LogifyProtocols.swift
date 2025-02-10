import Foundation

/// Основной логгер для приложения.
///
/// **Logify** предназначен для логирования сообщений, сетевых запросов и ответов с использованием системного
/// логгера **OS.Logger**. Логгер позволяет задавать уровень логирования и использовать категории для фильтрации сообщений.
///
/// ### Основные возможности:
/// - **Настраиваемый уровень логирования** – при инициализации можно задать минимальный уровень (например, `.debug`).
/// - **Форматирование сообщений** – каждое сообщение логируется с отметкой времени, именем файла, номером строки и именем функции.
/// - **Поддержка категорий** – сообщения можно логировать с указанием категории (например, `.networking`, `.ui` и т.д.).
/// - **Специальные методы для логирования запросов и ответов** – упрощают отладку сетевых операций.
///
/// Пример использования:
/// ```swift
/// // Инициализация логгера с уровнем .debug
/// let logger = Logify(logLevel: .debug)
///
/// // Логирование произвольного сообщения:
/// logger.log(.info, category: .analytics, "Произвольное информационное сообщение")
///
/// // Логирование сетевого запроса:
/// logger.logRequest(request)
/// ```
public protocol Logify {
    /// Инициализатор логгера.
    ///
    /// - Parameter logLevel: Минимальный уровень логирования. Сообщения с уровнем ниже будут отброшены.
    init(logLevel: LogLevel)
    
    func logMessage(
        _ level: LogLevel,
        category: LogCategory,
        _ message: String,
        function: String, // = #function
        file: String, //  = #file
        line: Int //  = #line
    )
    
    func logApiRequest(_ request: URLRequest, showBody: Bool)
    
    func logApiResponse(_ response: URLResponse?, data: Data?, showData: Bool)
}

public extension Logify {
    func log(
        _ level: LogLevel,
        category: LogCategory,
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        logMessage(level, category: category, message, function: function, file: file, line: line)
    }
    
    func logRequest(_ request: URLRequest, showBody: Bool = false) {
        logApiRequest(request, showBody: showBody)
    }
    
    func logResponse(_ response: URLResponse?, data: Data?, showData: Bool = false) {
        logApiResponse(response, data: data, showData: showData)
    }
}
