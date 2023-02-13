//
//  ElectionCourseItemView.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/2/13.
//

import SwiftUI

struct ElectionCourseListItemView: View {
    var info: Definitions.ElectionDataStructures.CourseInformation
    
    init(for info: Definitions.ElectionDataStructures.CourseInformation) {
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
    }
}

struct ElectionCourseDetailView: View {
    var info: Definitions.ElectionDataStructures.CourseInformation
    
    init(for info: Definitions.ElectionDataStructures.CourseInformation) {
        self.info = info
    }
    
    var body: some View {
        VStack {
            Text(info.opCode ?? "")
                .font(.title)
                .monospaced()
        }
        .navigationTitle(info.cname ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ElectionCourseItemView_Previews: PreviewProvider {
    static var previews: some View {
        ElectionCourseListItemView(for: .init(deptName: "", opRmName1: "", cursCode: "", cname: "", opCode: "", deptCode: "", opStdy: "", opType: "", dataToken: "", opTime1: "", opQuality: "", teacher: "", crossName: "", memo1: "", opRmName2: "", opTime2: "", nameStatus: "", mgDeptCode: "", opStdyDept: "", cursLang: "", divCode: "", beginTf: true, actionBits: "", crossType: ""))
            .previewDisplayName("Course List Row")
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
