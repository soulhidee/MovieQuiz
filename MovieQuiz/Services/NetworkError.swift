import Foundation

enum NetworkError: LocalizedError {
    case codeError
    case noData
    case decoding(Error)
    case network(Error)
    case imageDataCorrupted
    
    var errorDescription: String? {
        switch self {
        case .codeError:
            return "Сервер вернул неверный статус ответа."
        case .noData:
            return "Нет данных от сервера."
        case .decoding(let error):
            return "Ошибка при декодировании данных: \(error.localizedDescription)"
        case .network(let error):
            return "Сетевая ошибка: \(error.localizedDescription)"
        case.imageDataCorrupted:
            return "Не удалось загрузить изображение."
        }
    }
}
