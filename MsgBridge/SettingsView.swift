import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: MessageStore
    @AppStorage("serverAddress") private var serverAddress: String = ""
    @State private var status: String = ""
    @State private var syncing: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("电脑端地址"),
                        footer: Text("手机和电脑要连同一个 Wi-Fi。地址在电脑端程序启动时会显示出来。")) {
                    TextField("192.168.1.10:8765", text: $serverAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)
                }

                Section {
                    Button(action: sync) {
                        HStack {
                            if syncing {
                                ProgressView()
                                    .padding(.trailing, 6)
                            }
                            Text(syncing ? "正在同步…" : "立即同步")
                        }
                    }
                    .disabled(syncing || serverAddress.isEmpty)

                    if !status.isEmpty {
                        Text(status)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("本地数据")) {
                    HStack {
                        Text("已存消息")
                        Spacer()
                        Text("\(store.messages.count) 条")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("待办")
                        Spacer()
                        Text("\(store.todoCount) 条")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("已办")
                        Spacer()
                        Text("\(store.doneCount) 条")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("关于"),
                        footer: Text("消息只存在这台手机上，不上传任何服务器。")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("同步")
        }
    }

    private func sync() {
        syncing = true
        status = ""
        SyncService.fetch(from: serverAddress) { result in
            syncing = false
            switch result {
            case .success(let list):
                let added = store.merge(list)
                status = added > 0 ? "同步完成，新增 \(added) 条" : "同步完成，没有新消息"
            case .failure(let error):
                status = "同步失败：\(error.localizedDescription)"
            }
        }
    }
}
