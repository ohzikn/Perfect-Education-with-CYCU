//
//  CreditsView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        List {
            Section("個人資訊") {
                LabeledContent("姓名", value: currentSession.creditsInformation?.stdInfo?.userName ?? "")
                LabeledContent("學號", value: currentSession.creditsInformation?.stdInfo?.userId ?? "")
                LabeledContent("學院代號", value: currentSession.creditsInformation?.stdInfo?.departmentCode ?? "")
                LabeledContent("年級", value: currentSession.creditsInformation?.stdInfo?.departmentGradeName ?? "")
                LabeledContent("學生身份", value: currentSession.creditsInformation?.stdInfo?.typeName?.trimmingCharacters(in: .whitespaces) ?? "")
            }
            if let courseList = currentSession.creditsInformation?.stdCourseList {
                Section("修課資訊") {
                    ForEach(courseList) { item in
                        if let courseName = item.courseName {
                            NavigationLink {
                                CreditsCourseDetailView(courseItem: item)
                            } label: {
                                Text(courseName)
                            }

                        }
                    }
                }
            }
        }
        .navigationTitle("修課查詢")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Definitions.CreditsInformation.StdCourse.self) { value in
            CreditsCourseDetailView(courseItem: value)
        }
        .onAppear {
            Task {
                // Moved to root
//                await currentSession.requestCredits()
            }
        }
    }
}

struct CreditsCourseDetailView: View {
    let courseItem: Definitions.CreditsInformation.StdCourse
    
    var body: some View {
        List {
            LabeledContent("科目名稱", value: "\(courseItem.subjectName ?? "") (\(courseItem.subjectCode ?? ""))")
            LabeledContent("課程名稱", value: "\(courseItem.courseName ?? "") (\(courseItem.courseCode ?? ""))")
            LabeledContent("學類", value: courseItem.pKindName ?? "")
            LabeledContent("修課學年學期", value: courseItem.passYearTerm ?? "")
            LabeledContent("性質", value: courseItem.opQualityA ?? "")
            LabeledContent("學期", value: courseItem.termA ?? "")
            LabeledContent("學分", value: String(courseItem.opCreditA ?? 0))
            LabeledContent("分數", value: courseItem.scoreFinal ?? "")
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
            .environmentObject(CurrentSession())
    }
}
