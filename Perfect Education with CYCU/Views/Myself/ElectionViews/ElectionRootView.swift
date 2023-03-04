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
                ElectionRootView(rootDismiss: dismiss)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .navigationTitle("選課")
        .navigationBarTitleDisplayMode(.large)
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

struct ElectionRootView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var applicationParameters: ApplicationParameters
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    @State var takingList: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = []
    @State var trackingList: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = []
    @State var registrationList: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = []
    @State var waitingList: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = []
    
    var rootDismiss: DismissAction
    
    private enum SubsheetViews {
        case none
        case announcements
        case events
        case studentInfo
        case history
        
        case advancedSearch
    }
    @State private var currentSubSheetView: SubsheetViews = .none
    @State private var isSubSheetPresented = false
    
    enum CourseListType: String, CaseIterable {
        case search = "課程查詢"
        case takingList = "修課清單"
        case trackingList = "追蹤清單"
        case registrationList = "登記清單"
        case watingList = "遞補清單"
    }
    @State private var selectedCourseListType: CourseListType = .search
    
    enum GroupType: String, CaseIterable {
        case none = "無"
        case byOpType = "課程類別"
        case byTeacher = "授課老師"
        case byDept = "開課班級"
        
        func getGroupedResult(for courseList: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) -> Dictionary<String?, [Array<MyselfDefinitions.ElectionDataStructures.CourseInformation>.Element]>? {
            switch self {
            case .none:
                return nil
            case .byOpType:
                return Dictionary(grouping: courseList, by: \.opType)
            case .byTeacher:
                return Dictionary(grouping: courseList, by: \.teacher)
            case .byDept:
                return Dictionary(grouping: courseList, by: \.deptName)
            }
        }
    }
    @State private var selectedGroupType: GroupType = .none
    
    @State private var showSearchBar = true
    @State private var isFilterActivated: Bool = false
    @State private var searchEntry: String = ""
    @State private var searchResult: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = []
    
    private var courseSearchFieldView: CourseSearchFieldView {
        CourseSearchFieldView(isFilterActivated: $isFilterActivated, searchText: $searchEntry)
    }
    
    private func requestAddToTracklist(for courses: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) {
        Task {
            await currentMyselfSession.requestElection(method: .track_insert, courseInformation: courses)
        }
    }
    
    private func requestRemoveFromTracklist(for courses: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) {
        Task {
            await currentMyselfSession.requestElection(method: .track_del, courseInformation: courses)
        }
    }
    
    init(rootDismiss: DismissAction) {
        self.rootDismiss = rootDismiss
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showSearchBar { courseSearchFieldView }
                VStack {
                    switch selectedCourseListType {
                    case .search:
                        if currentSubSheetView == .advancedSearch {
                            // To prevent refresh indicator freezes (SwiftUI bug)
                            EmptyView()
                        } else if !searchResult.isEmpty {
                            ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: searchResult, groupBy: selectedGroupType)
                        } else {
                            ElectionPlaceholderEmptyItemView(courseListType: selectedCourseListType)
                        }
                    case .takingList:
                        if !takingList.isEmpty {
                            ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: takingList, groupBy: selectedGroupType)
                        } else {
                            ElectionPlaceholderEmptyItemView(courseListType: selectedCourseListType)
                        }
                    case .trackingList:
                        if !trackingList.isEmpty {
                            ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: trackingList, groupBy: selectedGroupType)
                        } else {
                            ElectionPlaceholderEmptyItemView(courseListType: selectedCourseListType)
                        }
                    case .registrationList:
                        if !registrationList.isEmpty {
                            ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: registrationList, groupBy: selectedGroupType)
                        } else {
                            ElectionPlaceholderEmptyItemView(courseListType: selectedCourseListType)
                        }
                    case .watingList:
                        if !waitingList.isEmpty {
                            ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: waitingList, groupBy: selectedGroupType)
                        } else {
                            ElectionPlaceholderEmptyItemView(courseListType: selectedCourseListType)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(selectedCourseListType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: [MyselfDefinitions.ElectionDataStructures.CourseInformation].self) { value in
                ElectionCourseItemsView(courseListType: selectedCourseListType, courseList: value, groupBy: .none)
            }
            .navigationDestination(for: MyselfDefinitions.ElectionDataStructures.CourseInformation.self) { value in
                ElectionCourseDetailView(for: value)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section {
                            Button {
                                currentSubSheetView = .announcements
                            } label: {
                                Label("選課公告", systemImage: "megaphone")
                            }
                            Button {
                                currentSubSheetView = .events
                            } label: {
                                Label("選課時間", systemImage: "calendar")
                            }
                        }
                        Section {
                            Button {
                                currentSubSheetView = .studentInfo
                            } label: {
                                Label("個人資訊", systemImage: "person.text.rectangle")
                            }
                            Button {
                                currentSubSheetView = .history
                            } label: {
                                Label("選課紀錄", systemImage: "clock")
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
                            Picker("分類方式", selection: $selectedGroupType) {
                                ForEach(GroupType.allCases, id: \.hashValue) { item in
                                    Text(item.rawValue)
                                        .tag(item)
                                }
                            }
                            .pickerStyle(.automatic)
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Picker("Course List Type", selection: $selectedCourseListType) {
                        ForEach(CourseListType.allCases, id: \.hashValue) { item in
                            Text(item.rawValue)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        // Fixed: Refreshable is not functioning if List view is not present due to empty query (Showing VStack with no items string instead).
        .refreshable {
            // Refresh student information and update lists
            switch selectedCourseListType {
            case .search:
                currentSubSheetView = .advancedSearch
            default:
                await currentMyselfSession.requestElection(method: .st_info_get)
            }
        }
        .onAppear {
//            Task {
                // Moved to root
//                await currentSession.requestElection(method: .ann_get)
//                await currentSession.requestElection(method: .stage_control_get)
//                await currentSession.requestElection(method: .st_base_info)
//                await currentSession.requestElection(method: .st_info_get)
//                await currentSession.requestElection(method: .st_record)
//            }
            // Load all course lists
            takingList = currentMyselfSession.electionInformation_studentInformation?.takeCourseList ?? []
            trackingList = currentMyselfSession.electionInformation_studentInformation?.trackList ?? []
            registrationList = currentMyselfSession.electionInformation_studentInformation?.registerList ?? []
            waitingList = currentMyselfSession.electionInformation_studentInformation?.makeUpList ?? []
        }
        // Sync subsheet view with isSubSheetPresented
        .onChange(of: isSubSheetPresented) { newValue in
            if !newValue { currentSubSheetView = .none }
        }
        .onChange(of: currentSubSheetView) { newValue in
            isSubSheetPresented = (newValue != .none)
        }
        .onChange(of: isFilterActivated) { newValue in
            if newValue { currentSubSheetView = .advancedSearch }
        }
        // Sync end
        .onChange(of: selectedCourseListType) { newValue in
            withAnimation(Animation.easeInOut(duration: 0.25)) {
                showSearchBar = (selectedCourseListType == .search)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .searchResultDidUpdate)) { notification in
            guard let response = notification.object as? MyselfDefinitions.ElectionDataStructures.CourseSearchRequestResponse, let courseData = response.courseData else { return }
            searchResult = courseData
        }
        .onReceive(NotificationCenter.default.publisher(for: .courseListDidUpdate)) { notification in
            guard let response = notification.object as? CurrentMyselfSession.CourseListType else { return }
            switch response {
            case .take:
                takingList = currentMyselfSession.electionInformation_studentInformation?.takeCourseList ?? []
            case .track:
                trackingList = currentMyselfSession.electionInformation_studentInformation?.trackList ?? []
            case .register:
                registrationList = currentMyselfSession.electionInformation_studentInformation?.registerList ?? []
            case .wait:
                waitingList = currentMyselfSession.electionInformation_studentInformation?.makeUpList ?? []
            }
        }
        .sheet(isPresented: $isSubSheetPresented) {
            switch currentSubSheetView {
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
            case .advancedSearch:
                ElectionAdvancedSearchView(inheritenced: _searchEntry)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled()
                    .onAppear {
                        searchEntry = String()
                    }
                    .onDisappear {
//                        searchEntry = ""
                    }
            }
        }
    }
}

struct ElectionPlaceholderEmptyItemView: View {
    let courseListType: ElectionRootView.CourseListType
    
    var body: some View {
        ZStack {
            if courseListType == .search {
                VStack {
                    Text("下拉來顯示搜尋選項")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            VStack(spacing: 4) {
                Text("沒有項目")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                if courseListType == .search {
                    Text("輸入文字或使用搜尋選項來查詢課程")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding([.bottom])
            ScrollView { }
        }
    }
}

struct ElectionViewDev: View {
    @EnvironmentObject var currentSession: CurrentMyselfSession
    
    var body: some View {
        List {
            ForEach(MyselfDefinitions.ElectionCommands.allCases, id: \.hashValue) { item in
                Button(item.rawValue) {
                    Task {
                        await currentSession.requestElection(method: item)
                    }
                }
            }
        }
        .navigationTitle("選課")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ElectionView_Previews: PreviewProvider {
    @Environment(\.dismiss) static var dismiss
    static var currentSession: CurrentMyselfSession {
        let session = CurrentMyselfSession()
        session.electionInformation_studentInformation = .init(alertText: nil, distinctIPIDCODEAlert: nil, language: nil, courseCacheKey: nil, announcementText: nil, dataSource: nil, isAuthorized: nil, crossTypeDefinitions: nil, departmentGroupDefinitions: nil, depqrtmentBuildingDefinitions: nil, departmentDefinitions: nil, generalOpDefinitions: nil, opDefinitions: nil, opStudyTypeDefinitions: nil, systemControl: nil, takeCourseList: nil, trackList: nil, registerList: nil, makeUpList: nil)
        return session
    }
    
    static var previews: some View {
        ElectionRootView(rootDismiss: dismiss)
            .environmentObject(ApplicationParameters())
            .environmentObject(CurrentMyselfSession())
            .previewDisplayName("Election View")
        ElectionViewDev()
            .environmentObject(CurrentMyselfSession())
            .previewDisplayName("Election View Dev")
    }
}
