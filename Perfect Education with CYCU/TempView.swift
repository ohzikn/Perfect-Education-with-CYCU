//
//  TempView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/13.
//

import SwiftUI

struct TempView: View {
    @EnvironmentObject var currentMyselfSession: CurrentMyselfSession
    
    private func getCrossInfo(_ id: UUID) -> MyselfDefinitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier? {
        var result: MyselfDefinitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier?
        
        if let definitions = currentMyselfSession.electionInformation_studentInformation?.crossTypeDefinitions {
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
