//
//  PortalServicesView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct PortalServicesView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    enum Services {
        case workStudy
        case mentor
        case election
        case credits
        case health
    }
    
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
                    NavigationLink("校內工讀", value: Services.workStudy)
                    NavigationLink("自選學術導師申請", value: Services.mentor)
                }
                Section("課業") {
                    NavigationLink("選課", value: Services.election)
                    NavigationLink("修課查詢", value: Services.credits)
                }
                Section("健康") {
                    NavigationLink("健康回報", value: Services.health)
                }
            }
            .navigationTitle("線上服務")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Services.self) { service in
                switch service {
                case .workStudy:
                    WorkStudyView()
                case .mentor:
                    MentorView()
                case .election:
                    ElectionView()
                case .credits:
                    CreditsView()
                case .health:
                    HealthView()
                }
            }
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
