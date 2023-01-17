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
            if let information =  currentSession.creditsInformation {
                Section("個人資訊") {
                    LabeledContent("姓名", value: information.stdInfo?.userName ?? "")
                    LabeledContent("學號", value: information.stdInfo?.userId ?? "")
                    LabeledContent("學院代號", value: information.stdInfo?.departmentCode ?? "")
                    LabeledContent("年級", value: information.stdInfo?.departmentGradeName ?? "")
                    LabeledContent("學生身份", value: information.stdInfo?.typeName?.trimmingCharacters(in: .whitespaces) ?? "")
                }
                Section("修課資訊") {
                    if let courseList = information.stdCourseList {
                        ForEach(courseList) { item in
                            if let courseName = item.courseName {
                                NavigationLink(value: item) {
                                    Text(courseName)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("修課查詢")
        .navigationDestination(for: Definitions.CreditsInformation.StdCourse.self) { courseItem in
            CourseDetailView(courseItem: courseItem)
        }
        .onAppear {
            currentSession.requestCredits()
        }
    }
}

struct CourseDetailView: View {
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
    }
}
