//
//  ElectionStudentBaseInformationView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/6.
//

import SwiftUI

struct ElectionStudentBaseInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    enum CreditType: String, CaseIterable {
        
        case general = "一般學分"
        case doubleMajor = "輔雙／學程外加學分"
        case overStudyByApply = "申請超修外加學分"
        case overStudyByResearch = "專題超修外加學分"
        
        func getCreditDetail(_ studentInformation: MyselfDefinitions.ElectionDataStructures.StudentBaseInformation.StudentInformation) -> CreditDetail? {
            switch self {
            case .general:
                if let maxLimit0 = studentInformation.maxLimit0, let creditTotalNormal = studentInformation.creditTotalNormal {
                    return .init(totalCredits: maxLimit0, usedCredits: creditTotalNormal)
                }
            case .doubleMajor:
                if let maxExtra = studentInformation.maxExtra, let creditAssist = studentInformation.creditAssist, let creditCross = studentInformation.creditCross, let creditDual = studentInformation.creditDual, let creditEduc = studentInformation.creditEduc, let creditEmpl = studentInformation.creditEmpl, let creditMicro = studentInformation.creditMicro, let creditPre = studentInformation.creditPre {
                     return .init(totalCredits: maxExtra, usedCredits: creditAssist + creditCross + creditDual + creditEduc + creditEmpl + creditMicro + creditPre)
                }
            case .overStudyByApply:
                if let extraCredits = studentInformation.extraCredits, let extraCreditsTotal = studentInformation.extraCreditsTotal {
                    return .init(totalCredits: extraCredits, usedCredits: extraCreditsTotal)
                }
            case .overStudyByResearch:
                if let topicCredit = studentInformation.topicCredit, let topicRCredit = studentInformation.topicRCredit {
                    return .init(totalCredits: topicCredit, usedCredits: topicRCredit)
                }
            }
            return nil
        }
    }
    
    struct CreditDetail: Identifiable {
        let id = UUID()
        let totalCredits: Int
        let usedCredits: Int
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let info = currentMyselfSession.electionInformation_studentBaseInformation?.studentsInformation?.first {
                    Section("基本資訊") {
                        LabeledContent("姓名", value: info.stmdName ?? "-")
                        LabeledContent("學號", value: info.idcode ?? "-")
                        LabeledContent("班級", value: info.stmdDptName ?? "-")
                        LabeledContent("教學評量問卷完成率", value: info.surveyFinishRate != nil ? "\(info.surveyFinishRate.unsafelyUnwrapped)%" : "-")
                        LabeledContent("可修習總學分上限", value: info.maxLimit != nil ? "\(info.maxLimit.unsafelyUnwrapped)" : "-")
                        LabeledContent("已選修總學分", value: info.creditTotal != nil ? "\(info.creditTotal.unsafelyUnwrapped)" : "-")
                    }
                    ForEach(CreditType.allCases, id: \.hashValue) { item in
                        if let creditDetail = item.getCreditDetail(info) {
                            Section("\(item.rawValue) (\(creditDetail.totalCredits))") {
                                LabeledContent("已選學分", value: "\(creditDetail.usedCredits)")
                                LabeledContent("剩餘學分", value: "\(creditDetail.totalCredits - creditDetail.usedCredits)")
                            }
                        }
                    }
                }
            }
//            .navigationDestination(for: RequestDestination.self) { value in
//                ElectionStudentInformationDetailView(requestDestination: value, parentDismiss: dismiss)
//            }
            .navigationTitle("個人資訊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
