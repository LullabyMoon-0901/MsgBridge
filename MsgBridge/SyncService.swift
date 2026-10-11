import Foundation

/// 从电脑端拉取消息。
///
/// 电脑端会开一个很小的 HTTP 服务，地址形如 http://192.168.1.10:8765
/// 手机和电脑连同一个 Wi-Fi 就能拉到数据。
enum SyncService {

    struct SyncError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    /// 把用户填的地址整理成合法的 URL
    static func normalize(_ raw: String) -> URL? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        if !text.hasPrefix("http://") && !text.hasPrefix("https://") {
            text = "http://" + text
        }
        if text.hasSuffix("/") {
            text.removeLast()
        }
        return URL(string: text + "/api/messages")
    }

    static func fetch(from rawAddress: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let url = normalize(rawAddress) else {
            completion(.failure(SyncError(message: "地址格式不对")))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(SyncError(message: "连不上电脑：\(error.localizedDescription)")))
                    return
                }
                guard let data = data else {
                    completion(.failure(SyncError(message: "电脑没有返回数据")))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let list = try decoder.decode([Message].self, from: data)
                    completion(.success(list))
                } catch {
                    completion(.failure(SyncError(message: "数据解析失败：\(error.localizedDescription)")))
                }
            }
        }.resume()
    }
}
