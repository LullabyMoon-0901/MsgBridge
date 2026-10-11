import SwiftUI

struct MessageDetailView: View {
    @EnvironmentObject var store: MessageStore
    let message: Message

    private var current: Message {
        store.messages.first(where: { $0.id == message.id }) ?? message
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(current.platform)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(platformColor.opacity(0.15))
                        .foregroundColor(platformColor)
                        .cornerRadius(6)
                    Spacer()
                    Text(fullDate)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Text(current.title.isEmpty ? "(无标题)" : current.title)
                    .font(.system(size: 20, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)

                if !current.body.isEmpty {
                    Text(current.body)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                Text("分类")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("分类", selection: Binding(
                    get: { current.tag },
                    set: { store.setTag(current, tag: $0) }
                )) {
                    ForEach(MessageTag.allCases) { tag in
                        Text(tag.rawValue).tag(tag)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Button(action: {
                    store.toggleStatus(current)
                }) {
                    HStack {
                        Image(systemName: current.status == .todo
                              ? "checkmark.circle"
                              : "arrow.uturn.left.circle")
                        Text(current.status == .todo ? "标记为已办" : "改回待办")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(current.status == .todo
                                ? Color.green.opacity(0.15)
                                : Color.orange.opacity(0.15))
                    .foregroundColor(current.status == .todo ? .green : .orange)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .navigationBarTitle("消息详情", displayMode: .inline)
    }

    private var platformColor: Color {
        switch current.platform {
        case "微信": return .green
        case "QQ":   return .blue
        case "钉钉": return .cyan
        default:     return .gray
        }
    }

    private var fullDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: current.date)
    }
}
