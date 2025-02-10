import Foundation
import os

public final class LogifyImpl: Logify {
    
    /// Идентификатор подсистемы, используемый для создания OS.Logger.
    /// Если не удалось получить Bundle.main.bundleIdentifier, используется значение по умолчанию.
    private let subsystem: String = Bundle.main.bundleIdentifier ?? LogifyConstants.defaultSubsystem
    
    /// Текущий уровень логирования.
    /// Сообщения с уровнем ниже этого значения игнорируются.
    private let currentLogLevel: LogLevel
    
    /// Инициализатор логгера.
    ///
    /// - Parameter logLevel: Минимальный уровень логирования. Сообщения с уровнем ниже будут отброшены.
    public init(logLevel: LogLevel) {
        self.currentLogLevel = logLevel
    }
    
    /// Возвращает экземпляр системного логгера OS.Logger для заданной категории.
    ///
    /// - Parameter category: Категория логирования.
    /// - Returns: Экземпляр `Logger`, настроенный на подсистему и указанную категорию.
    private func logger(for category: LogCategory) -> Logger {
        return Logger(subsystem: subsystem, category: category.rawValue)
    }
    
    /// Логирует сообщение с указанным уровнем, категорией и дополнительной информацией о месте вызова.
    ///
    /// Формат сообщения включает:
    /// - Префикс логгера (из `LogifyConstants`)
    /// - Отметку времени (формат ISO8601)
    /// - Имя файла, номер строки и название функции
    /// - Собственно сообщение
    ///
    /// - Parameters:
    ///   - level: Уровень логирования. Сообщение будет залогировано только если `level >= currentLogLevel`.
    ///   - category: Категория логирования (например, `.networking`, `.ui` и т.д.).
    ///   - message: Сообщение для логирования.
    ///   - function: Имя функции, вызывающей логирование (по умолчанию `#function`).
    ///   - file: Имя файла, в котором вызывается логирование (по умолчанию `#file`).
    ///   - line: Номер строки вызова логирования (по умолчанию `#line`).
    public func logMessage(
        _ level: LogLevel,
        category: LogCategory,
        _ message: String,
        function: String,
        file: String,
        line: Int
    ) {
        // Фильтрация по уровню логирования.
        guard level >= currentLogLevel else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let formattedMessage = "\(LogifyConstants.logPrefix): [\(timestamp)][\(fileName):\(line)] \(function) - \(message)"
        
        let logInstance = logger(for: category)
        logInstance.log(level: level.toOSLogLevel(), "\(formattedMessage, privacy: .public)")
    }
    
    
    /// Логирует HTTP-запрос.
    ///
    /// Метод логирует метод запроса, URL, а также (при наличии) HTTP-заголовки и тело запроса.
    /// Логирование происходит только если текущий уровень логирования равен `.debug`.
    ///
    /// - Parameters:
    ///   - request: Объект `URLRequest`, представляющий запрос.
    ///   - showBody: Флаг, определяющий, следует ли логировать тело запроса. По умолчанию `false`.
    public func logApiRequest(_ request: URLRequest, showBody: Bool) {
        guard currentLogLevel == .debug else { return }
        
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "UNKNOWN_URL"
        log(.debug, category: .networking, "\(LogifyConstants.requestPrefix) \(method) \(url)")
        
        if let headers = request.allHTTPHeaderFields {
            log(.debug, category: .networking, "\(LogifyConstants.headersPrefix) \(headers)")
        }
        
        if let body = request.httpBody, let json = String(data: body, encoding: .utf8), showBody {
            log(.debug, category: .networking, "\(LogifyConstants.bodyPrefix) \(json)")
        }
    }
    
    /// Логирует HTTP-ответ.
    ///
    /// Метод логирует статус ответа, а также (при наличии) данные ответа в формате JSON.
    /// Логирование происходит только если текущий уровень логирования равен `.debug`.
    ///
    /// - Parameters:
    ///   - response: Объект `URLResponse?`, полученный в результате запроса.
    ///   - data: Данные ответа.
    ///   - showData: Флаг, определяющий, следует ли логировать данные ответа. По умолчанию `false`.
    public func logApiResponse(_ response: URLResponse?, data: Data?, showData: Bool) {
        guard currentLogLevel == .debug else { return }
        
        if let httpResponse = response as? HTTPURLResponse {
            log(.debug, category: .networking, "\(LogifyConstants.responsePrefix) \(httpResponse.statusCode)")
        }
        
        if let data = data, let json = String(data: data, encoding: .utf8), showData {
            log(.debug, category: .networking, "\(LogifyConstants.responseJSONPrefix) \(json)")
        }
    }
}

/// Перечисление уровней логирования.
///
/// **LogLevel** задаёт возможные уровни логирования, позволяя фильтровать сообщения по их важности.
/// Каждый уровень имеет числовой приоритет, который используется для сравнения:
/// - **debug**: Наименьший приоритет (0).
/// - **info**: Приоритет 1.
/// - **warning**: Приоритет 2.
/// - **error**: Наивысший приоритет (3).
///
/// Также предоставляет метод для преобразования в тип `OSLogType`, необходимый для системного логирования.
public enum LogLevel: String, Comparable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    /// Числовой приоритет уровня логирования.
    var priority: Int {
        switch self {
        case .debug:   return 0
        case .info:    return 1
        case .warning: return 2
        case .error:   return 3
        }
    }
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.priority < rhs.priority
    }
    
    /// Преобразует текущий уровень логирования в соответствующий тип `OSLogType`.
    ///
    /// - Returns: Значение типа `OSLogType`, соответствующее уровню логирования.
    func toOSLogLevel() -> OSLogType {
        switch self {
        case .debug:   return .debug
        case .info:    return .info
        case .warning: return .default
        case .error:   return .error
        }
    }
}

/// Перечисление категорий логирования.
///
/// **LogCategory** позволяет классифицировать лог-сообщения по тематике, что упрощает фильтрацию и анализ логов.
/// Примеры категорий: сетевые операции, пользовательский интерфейс, аутентификация и т.д.
public enum LogCategory: String {
    case networking = "Networking"
    case ui = "UI"
    case authentication = "Authentication"
    case database = "Database"
    case analytics = "Analytics"
    case errorHandling = "ErrorHandling"
    case performance = "Performance"
    case lifecycle = "Lifecycle"
    case configuration = "Configuration"
    case debug = "Debug"
}
