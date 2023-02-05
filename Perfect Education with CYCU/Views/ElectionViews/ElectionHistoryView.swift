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
        NavigationStack {
            List {
                if let history = currentSession.electionInformation_history?.historyList {
                    ForEach(history) { item in
                        NavigationLink(value: item) {
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
            .navigationDestination(for: Definitions.ElectionInformation.History.HistoryItem.self) { value in
                List {
                    Group {
                        LabeledContent("課程名稱", value: value.cname ?? "-")
                        LabeledContent("課程類別", value: value.opType ?? "-")
                        LabeledContent("開課班級", value: value.deptName ?? "-")
                        LabeledContent("課程代碼", value: value.opCode ?? "-")
                        LabeledContent("必/選修", value: value.opStdyDept ?? "-")
                        LabeledContent("學分數", value: String(value.opCredit ?? 0))
                        LabeledContent("授課老師", value: value.teacher ?? "-")
                        LabeledContent("上課時間", value: value.opTime123 ?? "-")
                    }
                    Group {
                        LabeledContent("期程", value: value.opQuality ?? "-")
                        LabeledContent("選課狀態", value: value.statusName ?? "-")
                        LabeledContent("操作者", value: value.itemOperator ?? "-")
                        LabeledContent("記錄時間", value: value.updateTime?.getString() ?? "")
                            .monospacedDigit()
                    }
                }
                .navigationTitle(value.cname ?? "-")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") { dismiss() }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear {
            currentSession.requestElection(method: .st_record)
        }
    }
}
