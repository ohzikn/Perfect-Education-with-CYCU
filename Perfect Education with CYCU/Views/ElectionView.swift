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
                    Form {
                        Text("此選課功能為研究用途所開發，與中原大學沒有任何關係，中原大學不為此應用程式提供任何協助及技術支援。")
                        Text("此應用程式仍在開發階段，我們無法保證此應用程式的穩定性。")
                        Text("我們無法為此應用程式造成的任何損失負責，請留意。")
                        
                        Text("按下同意表示你已暸解上述內容並且希望繼續前往選課功能。")
                    }
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
    }
    
    @State private var currentSubsheetView: SubsheetViews = .none
    @State private var isSubSheetPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                
            }
            .navigationTitle("選課")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("離開") {
                        // Dismiss current fullscreen cover
                        dismiss()
                        // Dismiss root navigation
                        rootDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("選課公告") {
                            currentSubsheetView = .announcements
                        }
                        Button("選課時間") {
                            currentSubsheetView = .events
                        }
                        Button("個人資訊") {
                            currentSubsheetView = .studentInfo
                        }
                        Button("選課紀錄") {
                            currentSubsheetView = .history
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("課程清單") {
                        currentSubsheetView = .courseList
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
                ElectionStudentInformationView()
                    .presentationDetents([.large])
            case .history:
                ElectionHistoryView()
                    .presentationDetents([.large])
            case .courseList:
                ElectionCourseListView()
                    .presentationDetents([.large])
            }
        }
        .onAppear {
            applicationParameters.hideRootTabbar = true
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
        // Sync end
    }
}

struct ElectionAnnouncementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    @State var selectedAnnouncement: Definitions.ElectionDefinitions.AnnouncementRoles = .guide
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Announcement Type", selection: $selectedAnnouncement) {
                    ForEach(Definitions.ElectionDefinitions.AnnouncementRoles.allCases, id: \.hashValue) { item in
                        Text(item.getName(inChinese: true))
                            .tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                List {
                    if let billBoard = currentSession.electionInformation_announcement?.billboard, let filteredBillboard = billBoard.filter({ $0.announcementType == selectedAnnouncement.rawValue }), !filteredBillboard.isEmpty {
                        ForEach(filteredBillboard) { item in
                            NavigationLink(item.title ?? "沒有標題", value: item)
                        }
                    } else {
                        Text("沒有項目")
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(selectedAnnouncement.getName(inChinese: true))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .navigationDestination(for: Definitions.ElectionInformation.Announcement.Billboard.self) { value in
                ElectionAnnouncementDetailView(parentDismiss: dismiss, billboard: value)
            }
        }
        .onAppear {
            currentSession.requestElection(method: .ann_get)
        }
    }
}

struct ElectionAnnouncementDetailView: View {
    let parentDismiss: DismissAction
    let billboard: Definitions.ElectionInformation.Announcement.Billboard
    
    var body: some View {
        VStack {
            Text(billboard.title ?? "沒有標題")
                .font(.headline)
                .padding([.horizontal])
            Divider()
                .padding([.horizontal])
            WebView(markdown: billboard.content ?? "")
                .ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") { parentDismiss() }
            }
        }
    }
}

struct ElectionEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Definitions.ElectionDefinitions.Events.allCases, id: \.hashValue) { event in
                    if let eventName = Definitions.ElectionDefinitions.Events(rawValue: event.rawValue)?.getName(inChinese: true), let stageEvents = currentSession.electionInformation_stageControl?.stageEvents, let filteredStageEvents = stageEvents.filter({ $0.snStageType == event.rawValue }), !filteredStageEvents.isEmpty {
                        Section(eventName) {
                            ForEach(filteredStageEvents) { stageEvent in
                                NavigationLink(value: stageEvent) {
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
            .navigationDestination(for: Definitions.ElectionInformation.StageControl.StageEvent.self) { value in
                ElectionEventDetailView(parentDismiss: dismiss, event: value)
            }
        }
        .onAppear {
            currentSession.requestElection(method: .stage_control_get)
        }
    }
}

struct ElectionEventDetailView: View {
    let parentDismiss: DismissAction
    let event: Definitions.ElectionInformation.StageControl.StageEvent
    
    private func getActionString(_ queue: [Int]?) -> String? {
        guard let queue else { return nil }
        var resultArray: [String] = []
        Definitions.ElectionDefinitions.Actions.allCases.forEach { item in
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
        Definitions.ElectionDefinitions.PositionRoles.allCases.forEach { item in
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
        Definitions.ElectionDefinitions.CourseRoles.allCases.forEach { item in
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
        .navigationTitle(Definitions.ElectionDefinitions.Events(rawValue: event.snStageType ?? -1)?.getName(inChinese: true) ?? "選課階段代號 \(String(describing: event.snStageType))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") { parentDismiss() }
            }
        }
    }
}

struct ElectionStudentInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    enum CreditType: String, CaseIterable {
        
        case general = "一般學分"
        case doubleMajor = "輔雙／學程外加學分"
        case overStudyByApply = "申請超修外加學分"
        case overStudyByResearch = "專題超修外加學分"
        
//        private func getAvailableCredits(_ studentInformation: Definitions.ElectionInformation.StudentBaseInformation.StudentInformation) -> Int? {
//            switch self {
//            case .general:
//                return studentInformation.maxLimit0 ?? nil
//            case .doubleMajor:
//                return studentInformation.maxExtra ?? nil
//            case .overStudyByApply:
//                return studentInformation.extraCredits ?? nil
//            case .overStudyByResearch:
//                return studentInformation.topicCredit ?? nil
//            }
//        }
        
        func getCreditDetail(_ studentInformation: Definitions.ElectionInformation.StudentBaseInformation.StudentInformation) -> CreditDetail? {
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
        NavigationStack {
            Form {
                if let info = currentSession.electionInformation_studentInformation?.studentsInformation?.first {
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
        .onAppear {
            currentSession.requestElection(method: .st_base_info)
        }
    }
}

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

struct ElectionCourseListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    
    private enum CourseListType: String, CaseIterable {
        case takingList = "修課清單"
        case trackingList = "追蹤清單"
        case registrationList = "登記清單"
        case watingList = "遞補清單"
    }
    
    @State private var selectedCourseListType: CourseListType = .takingList
    
    private func updateCourseList() {
        switch selectedCourseListType {
        case .takingList:
            break
        case .trackingList:
            currentSession.requestElection(method: .track_get)
        case .registrationList:
            break
        case .watingList:
            break
        }
    }
    
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
                if selectedCourseListType == .takingList {
                    
                }
                if selectedCourseListType == .trackingList {
                    if let courses = currentSession.electionInformation_trackingList?.courses {
                        ForEach(courses) { course in
                            Text(course.cname ?? "")
                        }
                    }
                }
                if selectedCourseListType == .registrationList {
                    
                }
                if selectedCourseListType == .watingList {
                    
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
        .onAppear { updateCourseList() }
        .onChange(of: selectedCourseListType) { _ in updateCourseList() }
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
    static var previews: some View {
        ElectionView(rootDismiss: dismiss)
            .environmentObject(CurrentSession())
            .previewDisplayName("Election View")
        ElectionViewDev()
            .environmentObject(CurrentSession())
            .previewDisplayName("Election View Dev")
    }
}
