//
//  WorkStudyView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct WorkStudyView: View {
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    var body: some View {
        List {
            Section("資訊") {
                LabeledContent("Remote address", value: currentMyselfSession.workStudyInformation?.remoteAddress ?? "")
                LabeledContent("Fowarded for", value: currentMyselfSession.workStudyInformation?.xFowardedFor ?? "")
            }
            Section("工讀資料") {
                if let hireData = currentMyselfSession.workStudyInformation?.hireData, !hireData.isEmpty {
                    ForEach(hireData) { data in
                        Text(data.id.uuidString)
                    }
                } else {
                    Text("沒有項目")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("校內工讀")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await currentMyselfSession.requestWorkStudy()
            }
        }
    }
}

struct WorkStudyView_Previews: PreviewProvider {
    static var currentSession: CurrentMyselfSession = {
        var session = CurrentMyselfSession()
        return session
    }()
    static var previews: some View {
        WorkStudyView()
            .environmentObject(currentSession)
    }
}
