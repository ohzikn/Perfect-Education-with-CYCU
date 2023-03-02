//
//  ElectionEventView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/6.
//

import SwiftUI

struct ElectionEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    var body: some View {
        NavigationView {
            List {
                ForEach(MyselfDefinitions.ElectionDefinitions.Events.allCases, id: \.hashValue) { event in
                    if let eventName = MyselfDefinitions.ElectionDefinitions.Events(rawValue: event.rawValue)?.getName(inChinese: true), let stageEvents = currentMyselfSession.electionInformation_stageControl?.stageEvents, let filteredStageEvents = stageEvents.filter({ $0.snStageType == event.rawValue }), !filteredStageEvents.isEmpty {
                        Section(eventName) {
                            ForEach(filteredStageEvents) { stageEvent in
                                NavigationLink {
                                    ElectionEventDetailView(parentDismiss: dismiss, event: stageEvent)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(stageEvent.beginTime?.getString() ?? "")
                                                .monospacedDigit()
                                            Text("到 \(stageEvent.endTime?.getString() ?? "")")
                                                .monospacedDigit()
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if let edtime = stageEvent.endTime, Date.now > edtime {
                                            Text("已結束")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("選課時間")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

struct ElectionEventDetailView: View {
    let parentDismiss: DismissAction
    let event: MyselfDefinitions.ElectionDataStructures.StageControl.StageEvent
    
    private func getActionString(_ queue: [Int]?) -> String? {
        guard let queue else { return nil }
        var resultArray: [String] = []
        MyselfDefinitions.ElectionDefinitions.Actions.allCases.forEach { item in
            if queue.contains(item.rawValue) {
                resultArray.append(item.getName(inChinese: true))
            }
        }
        guard !resultArray.isEmpty else { return nil }
        return resultArray.joined(separator: ", ")
    }
    
    private func getRolesString(_ queue: [Int]?) -> String? {
        guard let queue else { return nil }
        var resultArray: [String] = []
        MyselfDefinitions.ElectionDefinitions.PositionRoles.allCases.forEach { item in
            if queue.contains(item.rawValue) {
                resultArray.append(item.getName(inChinese: true))
            }
        }
        guard !resultArray.isEmpty else { return nil }
        return resultArray.joined(separator: "\n")
    }
    
    private func getCourseRolesString(_ queue: [Int]?) -> String? {
        guard let queue else { return nil }
        var resultArray: [String] = []
        MyselfDefinitions.ElectionDefinitions.CourseRoles.allCases.forEach { item in
            if queue.contains(item.rawValue) {
                resultArray.append(item.getName(inChinese: true))
            }
        }
        guard !resultArray.isEmpty else { return nil }
        return resultArray.joined(separator: "\n")
    }
    
    var body: some View {
        Form {
            Section("選課資訊") {
                LabeledContent("開始時間") {
                    Text(event.beginTime?.getString() ?? "-")
                        .monospacedDigit()
                }
                LabeledContent("結束時間") {
                    Text(event.endTime?.getString() ?? "-")
                        .monospacedDigit()
                }
                LabeledContent("受理項目") {
                    Text(getActionString(event.actionBits) ?? "暫停受理")
                }
                LabeledContent("受理身份") {
                    Text(getRolesString(event.enterBits) ?? "暫停受理")
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("受理課程") {
                    Text(getCourseRolesString(event.enter3Bits) ?? "暫停受理")
                        .multilineTextAlignment(.trailing)
                }
            }
            if let remark = event.remark, !remark.isEmpty {
                Section("備注") {
                    Text(remark)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(MyselfDefinitions.ElectionDefinitions.Events(rawValue: event.snStageType ?? -1)?.getName(inChinese: true) ?? "選課階段代號 \(String(describing: event.snStageType))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") { parentDismiss() }
            }
        }
    }
}
