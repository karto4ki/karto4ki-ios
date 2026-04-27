import Foundation

/// Базовые URL без завершающего `/`.
///
/// Для загрузки файлов можно задать отдельный хост (например `http://192.168.0.33:8081`),
/// если gateway отдаёт только user-service, а file-storage на другом порту:
/// `SERVER_STORAGE_BASE_URL_SIMULATOR` / `SERVER_STORAGE_BASE_URL_DEVICE` в Info.plist.
enum ServerBaseURL {

    static var primaryAPIRoot: String {
        #if targetEnvironment(simulator)
        let preferredKey = "SERVER_BASE_URL_SIMULATOR"
        #else
        let preferredKey = "SERVER_BASE_URL_DEVICE"
        #endif

        if let preferred = Bundle.main.object(forInfoDictionaryKey: preferredKey) as? String,
           !preferred.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return trimSlash(preferred)
        }

        if let legacy = Bundle.main.object(forInfoDictionaryKey: "SERVER_BASE_URL") as? String,
           !legacy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return trimSlash(legacy)
        }

        fatalError("SERVER_BASE_URL_* not configured in Info.plist")
    }

    /// Хост для `POST /api/storage/v1.0/upload` и т.д.; по умолчанию совпадает с `primaryAPIRoot`.
    static var fileStorageAPIRoot: String {
        #if targetEnvironment(simulator)
        let key = "SERVER_STORAGE_BASE_URL_SIMULATOR"
        #else
        let key = "SERVER_STORAGE_BASE_URL_DEVICE"
        #endif
        if let s = Bundle.main.object(forInfoDictionaryKey: key) as? String,
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return trimSlash(s)
        }
        return primaryAPIRoot
    }

    private static func trimSlash(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}
