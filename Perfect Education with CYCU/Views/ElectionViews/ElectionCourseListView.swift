//
//  ElectionCourseListView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/6.
//

import SwiftUI

struct ElectionCourseListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    private enum CourseListType: String, CaseIterable {
        case takingList = "修課清單"
        case trackingList = "追蹤清單"
        case registrationList = "登記清單"
        case watingList = "遞補清單"
        
        func getCourseList(_ studentInformation: Definitions.ElectionInformation.StudentInformation) -> [Definitions.ElectionInformation.CourseInformation]? {
            switch self {
            case .takingList:
                return studentInformation.takeCourseList
            case .trackingList:
                return studentInformation.trackList
            case .registrationList:
                return studentInformation.registerList
            case .watingList:
                return studentInformation.makeUpList
            }
        }
    }
    
    @State private var selectedCourseListType: CourseListType = .takingList
    @State var presentedCourseList: [Definitions.ElectionInformation.CourseInformation]?
    
    var body: some View {
        NavigationStack {
            Picker("Course List Type", selection: $selectedCourseListType) {
                ForEach(CourseListType.allCases, id: \.hashValue) { item in
                    Text(item.rawValue)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal])
            List {
                if let presentedCourseList {
                    ForEach(presentedCourseList) { item in
                        Text(item.cname ?? "")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(selectedCourseListType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear {
            guard let studentInformation = currentSession.electionInformation_studentInformation else { return }
            presentedCourseList = selectedCourseListType.getCourseList(studentInformation)
        }
        .onChange(of: selectedCourseListType) { newValue in
            guard let studentInformation = currentSession.electionInformation_studentInformation else { return }
            presentedCourseList = newValue.getCourseList(studentInformation)
        }
    }
}
