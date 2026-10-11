import Foundation
import Combine

/// 消息仓库：负责本地持久化（存成 JSON 文件，放在 App 沙盒里）
final class MessageStore: ObservableObject {

    @Published var messages: [Message] = []

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent("messages.json")
        load()
    }

    // MARK: - 读写

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            messages = try decoder.decode([Message].self, from: data)
            sortDescending()
        } catch {
            print("加载本地消息失败: \(error)")
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(messages)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("保存本地消息失败: \(error)")
        }
    }

    // MARK: - 操作

    /// 合并电脑端同步过来的消息，按 id 去重
    @discardableResult
    func merge(_ incoming: [Message]) -> Int {
        let existing = Set(messages.map { $0.id })
        let fresh = incoming.filter { !existing.contains($0.id) }
        guard !fresh.isEmpty else { return 0 }
        messages.append(contentsOf: fresh)
        sortDescending()
        save()
        return fresh.count
    }

    func add(_ message: Message) {
        messages.insert(message, at: 0)
        save()
    }

    func toggleStatus(_ message: Message) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].status = (messages[idx].status == .todo) ? .done : .todo
        save()
    }

    func setTag(_ message: Message, tag: MessageTag) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].tag = tag
        save()
    }

    func delete(_ message: Message) {
        messages.removeAll { $0.id == message.id }
        save()
    }

    func delete(at offsets: IndexSet, in list: [Message]) {
        let targets = offsets.map { list[$0] }
        let ids = Set(targets.map { $0.id })
        messages.removeAll { ids.contains($0.id) }
        save()
    }

    // MARK: - 统计

    var todoCount: Int { messages.filter { $0.status == .todo }.count }
    var doneCount: Int { messages.filter { $0.status == .done }.count }

    private func sortDescending() {
        messages.sort { $0.date > $1.date }
    }
}
