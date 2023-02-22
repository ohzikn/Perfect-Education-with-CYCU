//
//  ElectionHistoryView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/6.
//

import SwiftUI

struct ElectionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        NavigationView {
            List {
                if let history = currentSession.electionInformation_history?.historyList {
                    ForEach(history) { item in
                        NavigationLink {
                            ElectionHistoryDetail(item: item, rootDismiss: dismiss)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.cname ?? "-")
                                        .lineLimit(1)
                                    Text(item.updateTime?.getString() ?? "")
                                        .monospacedDigit()
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.statusName ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("選課紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Definitions.ElectionDataStructures.History.HistoryItem.self) { value in
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .refreshable {
                // Refresh history and update lists
                await currentSession.requestElection(method: .st_record)
            }
        }
        .onAppear {
            Task {
                await currentSession.requestElection(method: .st_record)
            }
        }
    }
}

struct ElectionHistoryDetail: View {
    let item: Definitions.ElectionDataStructures.History.HistoryItem
    let rootDismiss: DismissAction
    
    var body: some View {
        List {
            Group {
                LabeledContent("課程名稱", value: item.cname ?? "-")
                LabeledContent("課程類別", value: item.opType ?? "-")
                LabeledContent("開課班級", value: item.deptName ?? "-")
                LabeledContent("課程代碼", value: item.opCode ?? "-")
                LabeledContent("必/選修", value: item.opStdyDept ?? "-")
                LabeledContent("學分數", value: String(item.opCredit ?? 0))
                LabeledContent("授課老師", value: item.teacher ?? "-")
            }
            Group {
                LabeledContent("上課時間", value: item.opTime123 ?? "-")
                LabeledContent("期程", value: item.opQuality ?? "-")
                LabeledContent("選課狀態", value: item.statusName ?? "-")
                LabeledContent("操作者", value: item.itemOperator ?? "-")
                LabeledContent("記錄時間", value: item.updateTime?.getString() ?? "")
                    .monospacedDigit()
            }
        }
        .navigationTitle(item.cname ?? "-")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") { rootDismiss() }
            }
        }
    }
}

struct ElectionHistoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        ElectionHistoryView()
    }
}
