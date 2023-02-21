//
//  WorkStudyView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/1/13.
//

import SwiftUI

struct WorkStudyView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    var body: some View {
        List {
            Section("資訊") {
                LabeledContent("Remote address", value: currentSession.workStudyInformation?.remoteAddress ?? "")
                LabeledContent("Fowarded for", value: currentSession.workStudyInformation?.xFowardedFor ?? "")
            }
            Section("工讀資料") {
                if let hireData = currentSession.workStudyInformation?.hireData, !hireData.isEmpty {
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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await currentSession.requestWorkStudy()
            }
        }
    }
}

struct WorkStudyView_Previews: PreviewProvider {
    static var currentSession: CurrentSession = {
        var session = CurrentSession()
        return session
    }()
    static var previews: some View {
        WorkStudyView()
            .environmentObject(currentSession)
    }
}
