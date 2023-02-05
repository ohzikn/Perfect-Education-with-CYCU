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
                ElectionStudentBaseInformationView()
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
        // Sync end
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
