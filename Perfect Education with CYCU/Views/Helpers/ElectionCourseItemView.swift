//
//  ElectionCourseItemView.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/2/13.
//

import SwiftUI

struct ElectionCourseItemsView: View {
    let courseListType: ElectionRootView.CourseListType
    let courseList: [MyselfDefinitions.ElectionDataStructures.CourseInformation]
    let groupBy: ElectionRootView.GroupType
    
    let columnDefinitions: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
    
    var body: some View {
        switch groupBy {
        case .none: // Show results by list
            List {
                switch courseListType {
                case .search:
                    ForEach(courseList) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    ElectionTrackingActionMenu(for: item, menuType: .swipeAction)
                                }
                                .contextMenu {
                                    ElectionTrackingActionMenu(for: item, menuType: .contextMenu)
                                }
                        }
                    }
                case .takingList:
                    ForEach(courseList) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    ElectionTrackingActionMenu(for: item, menuType: .swipeAction)
                                }
                                .contextMenu {
                                    ElectionTrackingActionMenu(for: item, menuType: .contextMenu)
                                }
                        }
                    }
                case .trackingList:
                    ForEach(courseList) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    ElectionTrackingActionMenu(for: item, menuType: .swipeAction)
                                }
                                .contextMenu {
                                    ElectionTrackingActionMenu(for: item, menuType: .contextMenu)
                                }
                        }
                    }
                case .registrationList:
                    ForEach(courseList) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    ElectionTrackingActionMenu(for: item, menuType: .swipeAction)
                                }
                                .contextMenu {
                                    ElectionTrackingActionMenu(for: item, menuType: .contextMenu)
                                }
                        }
                    }
                case .watingList:
                    ForEach(courseList) { item in
                        NavigationLink(value: item) {
                            ElectionCourseListItemView(for: item)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    ElectionTrackingActionMenu(for: item, menuType: .swipeAction)
                                }
                                .contextMenu {
                                    ElectionTrackingActionMenu(for: item, menuType: .contextMenu)
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
        default: // Show results by LazyVGrid
            ScrollView {
                LazyVGrid(columns: columnDefinitions, spacing: 20) {
                    if let grouped = groupBy.getGroupedResult(for: courseList) {
                        let sorted = grouped.keys.sorted(by: { ($0 ?? "").localizedStandardCompare($1 ?? "") == .orderedAscending })
                        ForEach(sorted, id: \.?.hashValue) { groupItem in
                            if let list: [MyselfDefinitions.ElectionDataStructures.CourseInformation] = grouped[groupItem] {
                                NavigationLink(value: list) {
                                    VStack {
                                        ZStack {
                                            Ellipse()
                                                .aspectRatio(contentMode: .fill)
                                                .foregroundColor(.gray)
                                            Text(groupItem?.prefix(1) ?? "其")
                                                .font(.largeTitle)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 80, height: 80)
                                        Text(groupItem ?? "其他")
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding([.vertical])
            }
        }
    }
}

struct ElectionCourseListItemView: View {
    var info: MyselfDefinitions.ElectionDataStructures.CourseInformation
    
    init(for info: MyselfDefinitions.ElectionDataStructures.CourseInformation) {
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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    var info: MyselfDefinitions.ElectionDataStructures.CourseInformation
    
    @State var isSyllabusSheetPresented = false
    
    init(for info: MyselfDefinitions.ElectionDataStructures.CourseInformation) {
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
                    Section {
                        ElectionTrackingActionMenu(for: info, menuType: .toolbarMenu)
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

struct ElectionTrackingActionMenu: View {
    @EnvironmentObject var currentSession: CurrentSession // Used only to execute election functions
    let courseItem: MyselfDefinitions.ElectionDataStructures.CourseInformation
    let menuType: MenuType
    
    enum MenuType {
        case swipeAction
        case contextMenu
        case toolbarMenu
    }
    
    init(for courseItem: MyselfDefinitions.ElectionDataStructures.CourseInformation, menuType: MenuType) {
        self.courseItem = courseItem
        self.menuType = menuType
    }
    
    private func requestAddToTracklist(for courses: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) {
        Task {
            await currentSession.requestElection(method: .track_insert, courseInformation: courses)
        }
    }
    
    private func requestRemoveFromTracklist(for courses: [MyselfDefinitions.ElectionDataStructures.CourseInformation]) {
        Task {
            await currentSession.requestElection(method: .track_del, courseInformation: courses)
        }
    }
    
    var body: some View {
        Group {
            switch menuType {
            case .swipeAction:
                Button(role: .none) {
                    requestAddToTracklist(for: [courseItem])
                } label: {
                    Label("新增", systemImage: "text.badge.plus")
                }
                .tint(.blue)
                Button(role: .destructive) {
                    requestRemoveFromTracklist(for: [courseItem])
                } label: {
                    Label("移除", systemImage: "text.badge.minus")
                }
                .tint(.orange)
            case .contextMenu, .toolbarMenu:
                Button(role: .none) {
                    requestAddToTracklist(for: [courseItem])
                } label: {
                    Label("新增至追蹤清單", systemImage: "text.badge.plus")
                }
                Button(role: .destructive) {
                    requestRemoveFromTracklist(for: [courseItem])
                } label: {
                    Label("從追蹤清單移除", systemImage: "text.badge.minus")
                }
            }
        }
    }
}

struct ElectionCourseItemView_Previews: PreviewProvider {
    static var courseInformation: MyselfDefinitions.ElectionDataStructures.CourseInformation = .init(deptName: "", opRmName1: "教學113", cursCode: "", cname: "熱力學", opCode: "ABCD12", deptCode: "", opStdy: "", opType: "", dataToken: "", opTime1: "1-34", opQuality: "", teacher: "", crossName: "", memo1: "Memo", opRmName2: "", opTime2: "", nameStatus: "", mgDeptCode: "", opStdyDept: "", cursLang: "", divCode: "", beginTf: true, actionBits: "", crossType: "")
    
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
