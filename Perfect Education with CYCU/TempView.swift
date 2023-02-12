//
//  TempView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/13.
//

import SwiftUI

struct TempView: View {
    @EnvironmentObject var currentSession: CurrentSession
    
    private func getCrossInfo(_ id: UUID) -> Definitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier? {
        var result: Definitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier?
        
        if let definitions = currentSession.electionInformation_studentInformation?.crossTypeDefinitions {
            definitions.forEach { crossType in
                if let target = crossType.crossIdentifiers?.first(where: { $0.id == id }) {
                    result = target
                }
            }
        }
        return result
    }
    
    var body: some View {
        VStack {
            Text(getCrossInfo(UUID())?.crossName ?? "")
        }
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
