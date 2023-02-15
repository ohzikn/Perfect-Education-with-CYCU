//
//  ElectionCourseItemView.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/2/13.
//

import SwiftUI

struct ElectionCourseListItemView: View {
    var info: Definitions.ElectionDataStructures.CourseInformation
    
    init(for info: Definitions.ElectionDataStructures.CourseInformation) {
        self.info = info
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(info.cname ?? "-")
            HStack {
                Text(info.opCode ?? "-")
                    .monospaced()
                Text(info.deptName ?? "")
                Text(info.teacher ?? "")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .lineLimit(1)
    }
}

struct ElectionCourseDetailView: View {
    @EnvironmentObject var currentSession: CurrentSession
    var info: Definitions.ElectionDataStructures.CourseInformation
    
    @State var isSyllabusSheetPresented = false
    
    init(for info: Definitions.ElectionDataStructures.CourseInformation) {
        self.info = info
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let cname = info.cname {
                    Text(cname)
                        .font(.title3)
                        .fontWeight(.semibold)
//                        .multilineTextAlignment(.center)
                }
                if let opCode = info.opCode {
                    Text(opCode)
                        .font(.title3)
                        .monospaced()
                }
                if let opTime1 = info.opTime1 {
                    Divider()
                    LabeledContent("上課資訊", value: "\(opTime1)" + (info.opRmName1 != nil ? " 在 \(info.opRmName1.unsafelyUnwrapped)" : ""))
                        .monospacedDigit()
                    if let opTime2 = info.opTime2 {
                        LabeledContent("", value: "\(opTime2)" + (info.opRmName2 != nil ? " 在 \(info.opRmName2.unsafelyUnwrapped)" : ""))
                            .monospacedDigit()
                    }
                }
                if let opType = info.opType {
                    Divider()
                    LabeledContent("課程類別", value: opType)
                }
                if let deptName = info.deptName {
                    Divider()
                    LabeledContent("開課班級", value: deptName)
                }
                if let teacher = info.teacher {
                    Divider()
                    LabeledContent("授課老師", value: teacher)
                }
                if let opStdy = info.opStdy {
                    Divider()
                    LabeledContent("必/選修", value: opStdy)
                }
                if let opCredit = info.opCredit {
                    Divider()
                    LabeledContent("學分數", value: String(opCredit))
                }
                if let memo1 = info.memo1 {
                    Divider()
                    HStack {
                        Text(memo1)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding([.vertical])
                }
            }
            .padding([.horizontal])
        }
//        .navigationTitle("課程資訊")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section {
                        Button {
                            isSyllabusSheetPresented.toggle()
                        } label: {
                            Label("瀏覽課綱", systemImage: "doc.plaintext")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

            }
        }
        .fullScreenCover(isPresented: $isSyllabusSheetPresented) {
            SFSafariView(syllabusInfo: .init(yearTerm: currentSession.electionInformation_studentInformation?.systemControl?.yearTerm ?? "", opCode: info.opCode ?? ""))
                .ignoresSafeArea()
        }
    }
}

struct ElectionCourseItemView_Previews: PreviewProvider {
    static var courseInformation: Definitions.ElectionDataStructures.CourseInformation = .init(deptName: "", opRmName1: "教學113", cursCode: "", cname: "熱力學", opCode: "ABCD12", deptCode: "", opStdy: "", opType: "", dataToken: "", opTime1: "1-34", opQuality: "", teacher: "", crossName: "", memo1: "Memo", opRmName2: "", opTime2: "", nameStatus: "", mgDeptCode: "", opStdyDept: "", cursLang: "", divCode: "", beginTf: true, actionBits: "", crossType: "")
    
    static var previews: some View {
        NavigationStack {
            ElectionCourseDetailView(for: courseInformation)
        }
        .previewDisplayName("Course Detail")
        ElectionCourseListItemView(for: courseInformation)
            .previewDisplayName("Course List Row")
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
