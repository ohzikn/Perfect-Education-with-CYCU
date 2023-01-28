//
//  PortalServicesView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct PortalServicesView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        NavigationView {
            List {
//                Section("Developer") {
//                    Button("Get work study data") {
//                        currentSession.requestWorkStudy()
//                    }
//                }
                Section("生活") {
                    NavigationLink("校內工讀", destination: WorkStudyView())
                    NavigationLink("自選學術導師申請", destination: MentorView())
                }
                Section("課業") {
                    NavigationLink("選課", destination: ElectionPlaceholderView())
                    NavigationLink("選課（開發）", destination: ElectionViewDev())
                    NavigationLink("修課查詢", destination: CreditsView())
                }
                Section("健康") {
                    NavigationLink("健康回報", destination: HealthView())
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("線上服務")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct PortalServicesView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        PortalServicesView()
            .environmentObject(currentSession)
    }
}
