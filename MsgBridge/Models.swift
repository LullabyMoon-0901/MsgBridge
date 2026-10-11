import Foundation

/// 消息分类
enum MessageTag: String, Codable, CaseIterable, Identifiable {
    case homework = "作业提醒"
    case activity = "活动提醒"
    case notice = "通知公告"
    case other = "其他"

    var id: String { rawValue }
}

/// 处理状态
enum MessageStatus: String, Codable, CaseIterable, Identifiable {
    case todo = "待办"
    case done = "已办"

    var id: String { rawValue }
}

/// 一条聚合后的工作消息
struct Message: Identifiable, Codable, Hashable {
    var id: String
    var platform: String
    var title: String
    var body: String
    var date: Date
    var tag: MessageTag
    var status: MessageStatus

    private enum CodingKeys: String, CodingKey {
        case id, platform, title, body, date, tag, status
    }

    init(id: String = UUID().uuidString,
         platform: String,
         title: String,
         body: String,
         date: Date = Date(),
         tag: MessageTag = .other,
         status: MessageStatus = .todo) {
        self.id = id
        self.platform = platform
        self.title = title
        self.body = body
        self.date = date
        self.tag = tag
        self.status = status
    }

    /// 电脑端发来的 JSON 可能缺字段，这里做一次容错解码
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        platform = (try? c.decode(String.self, forKey: .platform)) ?? "未知"
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        body = (try? c.decode(String.self, forKey: .body)) ?? ""
        date = (try? c.decode(Date.self, forKey: .date)) ?? Date()
        let tagRaw = (try? c.decode(String.self, forKey: .tag)) ?? ""
        tag = MessageTag(rawValue: tagRaw) ?? .other
        let statusRaw = (try? c.decode(String.self, forKey: .status)) ?? ""
        status = MessageStatus(rawValue: statusRaw) ?? .todo
    }
}
