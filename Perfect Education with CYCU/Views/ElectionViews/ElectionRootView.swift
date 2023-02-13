//
//  ElectionView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct ElectionPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationParameters: ApplicationParameters
    
    @State var isWelcomeSheetPresented: Bool = false
    @State var didAcceptTerms: Bool = false
    
    var body: some View {
        ZStack {
            if didAcceptTerms {
                ElectionView(rootDismiss: dismiss)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isWelcomeSheetPresented) {
            NavigationStack {
                VStack {
                    List {
                        Text("此選課功能為研究用途所開發，與中原大學沒有任何關係，中原大學不為此應用程式提供任何協助及技術支援。")
                        Text("此應用程式仍在開發階段，我們無法保證此應用程式的穩定性。")
                        Text("我們無法為此應用程式造成的任何損失負責，請留意。")
                        Text("按下同意表示你已暸解上述內容並且希望繼續前往選課功能。")
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("條款與約定")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("取消") {
                            didAcceptTerms = false
                            isWelcomeSheetPresented = false
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("不同意") {
                            didAcceptTerms = false
                            isWelcomeSheetPresented = false
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("同意") {
                            didAcceptTerms = true
                            isWelcomeSheetPresented = false
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
        }
        .onAppear {
            isWelcomeSheetPresented = true
        }
    }
}

struct ElectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentSession: CurrentSession
    
    var rootDismiss: DismissAction
    
    private enum SubsheetViews {
        case none
        case announcements
        case events
        case studentInfo
        case history
        case courseList
        
        case searchFilter
    }
    
    @State private var currentSubsheetView: SubsheetViews = .none
    @State private var isSubSheetPresented = false
    
    @State private var isFilterActivated: Bool = false
    @State private var searchEntry: String = ""
    @State private var searchResult: [Definitions.ElectionDataStructures.CourseInformation]?
    
    private var courseSearchFieldView: CourseSearchFieldView {
        CourseSearchFieldView(isFilterActivated: $isFilterActivated, searchText: $searchEntry)
    }
    
    var body: some View {
        NavigationStack {
            courseSearchFieldView
//            Text(searchEntry)
            List {
                if let searchResult {
                    ForEach(searchResult) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                        }
//                        Text(item.cname ?? "-")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("選課")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Definitions.ElectionDataStructures.CourseInformation.self) { value in
                ElectionCourseDetailView(for: value)
            }
//            .searchable(text: $searchEntry)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section {
                            Button {
                                currentSubsheetView = .announcements
                            } label: {
                                Label("選課公告", systemImage: "megaphone")
                            }
                            Button {
                                currentSubsheetView = .events
                            } label: {
                                Label("選課時間", systemImage: "calendar")
                            }
                        }
                        Section {
                            Button {
                                currentSubsheetView = .studentInfo
                            } label: {
                                Label("個人資訊", systemImage: "person.text.rectangle")
                            }
                            Button {
                                currentSubsheetView = .history
                            } label: {
                                Label("選課紀錄", systemImage: "clock")
                            }
                            Button{
                                currentSubsheetView = .courseList
                            } label: {
                                Label("課程清單", systemImage: "list.bullet.rectangle.portrait")
                            }
                        }
                        Section {
                            Button("離開") {
                                // Dismiss current fullscreen cover
                                dismiss()
                                // Dismiss root navigation
                                rootDismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            Menu("顯示方式選項") {
                                Section("分類方式：") {
                                    Button("課程名稱") {
                                        
                                    }
                                    Button("開課代碼") {
                                        
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $isSubSheetPresented) {
            switch currentSubsheetView {
            case .none:
                EmptyView()
            case .announcements:
                ElectionAnnouncementView()
                    .presentationDetents([.large])
            case .events:
                ElectionEventView()
                    .presentationDetents([.large])
            case .studentInfo:
                ElectionStudentBaseInformationView()
                    .presentationDetents([.large])
            case .history:
                ElectionHistoryView()
                    .presentationDetents([.large])
            case .courseList:
                ElectionCourseListView()
                    .presentationDetents([.large])
            case .searchFilter:
                ElectionAdvancedSearchView(inheritenced: _searchEntry)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled()
                    .onDisappear {
//                        searchEntry = ""
                    }
            }
        }
        .onAppear {
            applicationParameters.hideRootTabbar = true
            currentSession.requestElection(method: .ann_get)
            currentSession.requestElection(method: .stage_control_get)
            currentSession.requestElection(method: .st_base_info)
            currentSession.requestElection(method: .st_info_get)
        }
        .onDisappear {
            applicationParameters.hideRootTabbar = false
        }
        // Sync subsheet view with isSubSheetPresented
        .onChange(of: isSubSheetPresented) { newValue in
            if !newValue { currentSubsheetView = .none }
        }
        .onChange(of: currentSubsheetView) { newValue in
            isSubSheetPresented = (newValue != .none)
        }
        .onChange(of: isFilterActivated) { newValue in
            if newValue { currentSubsheetView = .searchFilter }
        }
        // Sync end
        .onReceive(NotificationCenter.default.publisher(for: .searchResultDidUpdate)) { notification in
            guard let response = notification.object as? Definitions.ElectionDataStructures.CourseSearchRequestResponse, let courseData = response.courseData else { return }
            searchResult = courseData
        }
    }
}



struct ElectionViewDev: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        List {
            ForEach(Definitions.ElectionCommands.allCases, id: \.hashValue) { item in
                Button(item.rawValue) {
                    currentSession.requestElection(method: item)
                }
            }
        }
        .navigationTitle("選課")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ElectionView_Previews: PreviewProvider {
    @Environment(\.dismiss) static var dismiss
    static var currentSession: CurrentSession {
        let session = CurrentSession()
        session.electionInformation_studentInformation = .init(alertText: nil, distinctIPIDCODEAlert: nil, language: nil, courseCacheKey: nil, announcementText: nil, dataSource: nil, isAuthorized: nil, crossTypeDefinitions: nil, departmentGroupDefinitions: nil, depqrtmentBuildingDefinitions: nil, departmentDefinitions: nil, generalOpDefinitions: nil, opDefinitions: nil, opStudyTypeDefinitions: nil, takeCourseList: nil, trackList: nil, registerList: nil, makeUpList: nil)
        return session
    }
    
    static var previews: some View {
        ElectionView(rootDismiss: dismiss)
            .environmentObject(ApplicationParameters())
            .environmentObject(CurrentSession())
            .previewDisplayName("Election View")
        ElectionViewDev()
            .environmentObject(CurrentSession())
            .previewDisplayName("Election View Dev")
    }
}
