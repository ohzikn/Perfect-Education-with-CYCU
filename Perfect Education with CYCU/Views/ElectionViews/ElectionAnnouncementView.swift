//
//  ElectionAnnouncementView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/6.
//

import SwiftUI

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
            .navigationDestination(for: Definitions.ElectionDataStructures.Announcement.Billboard.self) { value in
                ElectionAnnouncementDetailView(parentDismiss: dismiss, billboard: value)
            }
        }
    }
}

struct ElectionAnnouncementDetailView: View {
    let parentDismiss: DismissAction
    let billboard: Definitions.ElectionDataStructures.Announcement.Billboard
    
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
