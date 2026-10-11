import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var store: MessageStore
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all = "全部"
        case todo = "待办"
        case done = "已办"

        var id: String { rawValue }
    }

    private var list: [Message] {
        switch filter {
        case .all:  return store.messages
        case .todo: return store.messages.filter { $0.status == .todo }
        case .done: return store.messages.filter { $0.status == .done }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("", selection: $filter) {
                    ForEach(Filter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)

                if list.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(list) { message in
                            NavigationLink(destination: MessageDetailView(message: message)) {
                                MessageRow(message: message)
                            }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets, in: list)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("工作消息")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("还没有消息")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Text("去「同步」页拉取电脑端的数据")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(platformColor.opacity(0.15))
                .frame(width: 38, height: 38)
                .overlay(
                    Text(shortPlatform)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(platformColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(message.title.isEmpty ? "(无标题)" : message.title)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if message.status == .done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                    }
                }

                if !message.body.isEmpty {
                    Text(message.body)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 6) {
                    Text(message.tag.rawValue)
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(4)
                    Text(shortDate)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var shortPlatform: String {
        switch message.platform {
        case "微信": return "微"
        case "QQ":   return "Q"
        case "钉钉": return "钉"
        default:     return String(message.platform.prefix(1))
        }
    }

    private var platformColor: Color {
        switch message.platform {
        case "微信": return .green
        case "QQ":   return .blue
        case "钉钉": return .cyan
        default:     return .gray
        }
    }

    private var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: message.date)
    }
}
