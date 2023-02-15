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
        
        func getCourseList(_ studentInformation: Definitions.ElectionDataStructures.StudentInformation) -> [Definitions.ElectionDataStructures.CourseInformation]? {
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
    @State var presentedCourseList: [Definitions.ElectionDataStructures.CourseInformation]?
    
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
            VStack {
                if let presentedCourseList, !presentedCourseList.isEmpty {
                    List {
                        switch selectedCourseListType {
                        case .takingList:
                            ForEach(presentedCourseList) { item in
                                NavigationLink(value: item) {
                                    ElectionCourseListItemView(for: item)
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(role: .none) {
                                                
                                            } label: {
                                                Label("新增", systemImage: "text.badge.plus")
                                            }
                                            .tint(.orange)
                                            Button(role: .destructive) {
                                                
                                            } label: {
                                                Label("移除", systemImage: "text.badge.minus")
                                            }
                                            .tint(.orange)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button("退選", role: .destructive) {
                                                
                                            }
                                        }
                                }
                            }
                        case .trackingList:
                            ForEach(presentedCourseList) { item in
                                NavigationLink(value: item) {
                                    ElectionCourseListItemView(for: item)
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                
                                            } label: {
                                                Label("移除", systemImage: "text.badge.minus")
                                            }
                                            .tint(.orange)
                                        }
                                }
                            }
                        case .registrationList:
                            ForEach(presentedCourseList) { item in
                                NavigationLink(value: item) {
                                    ElectionCourseListItemView(for: item)
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                
                                            } label: {
                                                Label("移除", systemImage: "text.badge.minus")
                                            }
                                            .tint(.orange)
                                        }
                                }
                            }
                        case .watingList:
                            ForEach(presentedCourseList) { item in
                                NavigationLink(value: item) {
                                    ElectionCourseListItemView(for: item)
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                
                                            } label: {
                                                Label("移除", systemImage: "text.badge.minus")
                                            }
                                            .tint(.orange)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text("沒有項目")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding([.bottom])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(selectedCourseListType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Definitions.ElectionDataStructures.CourseInformation.self) { value in
                ElectionCourseDetailView(for: value)
            }
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
