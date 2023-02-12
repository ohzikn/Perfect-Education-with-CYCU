//
//  ElectionAdvancedSearchView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/12.
//

import SwiftUI

struct ElectionAdvancedSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentSession: CurrentSession
    // MARK: Text fields
    @State var selectedDepartmentIds: [String] = []
    @State var selectedDepartmentGroupId: String?
    @State var selectedCrossId: String?
    @State var selectedStudyTypeId: String?
    @State var emiCourseToggle: Bool = false
    
    @State var opCode_Entry = ""
    @State var cName_Entry = ""
    @State var teacher_Entry = ""
    
    @State var selectedCreditsOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedCreditsValue1: Int = -1
    @State var selectedCreditsValue2: Int = -1
    
    @State var selectedManCurrentOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManCurrentValue1: Int = -1
    @State var selectedManCurrentValue2: Int = -1
    
    @State var selectedManSumOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManSumValue1: Int = -1
    @State var selectedManSumValue2: Int = -1
    
    @State var selectedManRemainOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManRemainValue1: Int = -1
    @State var selectedManRemainValue2: Int = -1
    
    @State var selectedManRegisterOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManRegisterValue1: Int = -1
    @State var selectedManRegisterValue2: Int = -1
    
    @State var selectedNonStopValue: Int = 0
    @State var selectedBetDeptValue: Int = 0
    @State var selectedBetBlnValue: Int = 0
    @State var selectedBetBlnMdieValue: Int = 0
    @State var selectedCrossPblValue: Int = 0
    @State var selectedDistanceCourseValue: Int = 0
    
    var body: some View {
        NavigationStack {
            List {
                if let studentInfo = currentSession.electionInformation_studentInformation {
                    Group {
                        NavigationLink {
                            List {
                                if let definitions = studentInfo.departmentDefinitions {
                                    let groupedDefinitions = Dictionary(grouping: definitions) { $0.codName }
                                    let sortedDefinitions = groupedDefinitions.keys.sorted(by: { $0?.localizedStandardCompare($1 ?? "") == .orderedAscending })
                                    ForEach(sortedDefinitions, id: \.?.hashValue) { groupItem in
                                        Section(groupItem ?? "-") {
                                            ForEach(groupedDefinitions[groupItem] ?? []) { item in
                                                Text(item.adminDeptName ?? "-")
                                                    .tag(item.adminCode)
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("開課學系")
                                Spacer()
                                Text("Overview")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Picker("部別", selection: $selectedDepartmentGroupId) {
                            if let definitions = studentInfo.departmentGroupDefinitions {
                                Text("不指定")
                                    .tag("" as String?)
                                ForEach(definitions) { item in
                                    Text(item.name ?? "-")
                                        .tag(item.deptDiv)
                                }
                            }
                        }
                        LabeledContent("課程代碼") {
                            TextField("選填", text: $opCode_Entry)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("課程名稱") {
                            TextField("選填", text: $cName_Entry)
                                .multilineTextAlignment(.trailing)
                        }
                        NavigationLink {
                            if let definitions = studentInfo.opDefinitions {
                                List(definitions) { item in
                                    Text(item.name ?? "-")
                                        .tag(item.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text("通識類別")
                                Spacer()
                                Text("Overview")
                                    .foregroundColor(.secondary)
                            }
                        }
                        NavigationLink {
                            if let definitions = studentInfo.generalOpDefinitions {
                                List(definitions) { item in
                                    Text(item.name ?? "-")
                                        .tag(item.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text("課程類別")
                                Spacer()
                                Text("Overview")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Picker("跨就微學程", selection: $selectedCrossId) {
                            if let definitions = studentInfo.crossTypeDefinitions {
                                Text("不指定")
                                    .tag("" as String?)
                                ForEach(definitions) { item in
                                    Text(item.name ?? "-")
                                        .tag(item.name)
                                }
                            }
                        }
                        Picker("必/選修", selection: $selectedStudyTypeId) {
                            if let definitions = studentInfo.opStudyTypeDefinitions {
                                Text("不指定")
                                    .tag("" as String?)
                                ForEach(definitions) { item in
                                    Text(item.name ?? "-")
                                        .tag(item.name)
                                }
                            }
                        }
                        AdvancedSearchRangePickerView(title: "學分數", selectedOperator: $selectedCreditsOperator, value1: $selectedCreditsValue1, value2: $selectedCreditsValue2)
                        LabeledContent("授課教師") {
                            TextField("選填", text: $teacher_Entry)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    Group {
                        NavigationLink {
                            
                        } label: {
                            HStack {
                                Text("上課時間")
                                Spacer()
                                Text("Not Implemented")
                                    .foregroundColor(.secondary)
                            }
                        }
                        AdvancedSearchRangePickerView(title: "已選人數", selectedOperator: $selectedManCurrentOperator, value1: $selectedManCurrentValue1, value2: $selectedManCurrentValue2)
                        AdvancedSearchRangePickerView(title: "選課名額", selectedOperator: $selectedManSumOperator, value1: $selectedManSumValue1, value2: $selectedManSumValue2)
                        AdvancedSearchRangePickerView(title: "篩選餘額", selectedOperator: $selectedManRemainOperator, value1: $selectedManRemainValue1, value2: $selectedManRemainValue2)
                        AdvancedSearchRangePickerView(title: "登記人數", selectedOperator: $selectedManRegisterOperator, value1: $selectedManRegisterValue1, value2: $selectedManRegisterValue2)
                    }
                    Toggle("全英語課程", isOn: $emiCourseToggle)
                    Picker("停修", selection: $selectedNonStopValue) {
                        Text("不指定")
                            .tag(0)
                        Text("不得停修")
                            .tag(1)
                        Text("得停修")
                            .tag(2)
                    }
                    Picker("跨系", selection: $selectedBetDeptValue) {
                        Text("不指定")
                            .tag(0)
                        Text("不可跨系")
                            .tag(1)
                        Text("可跨系")
                            .tag(2)
                    }
                    Picker("跨系", selection: $selectedBetBlnValue) {
                        Text("不指定")
                            .tag(0)
                        Text("不可跨部")
                            .tag(1)
                        Text("可跨部")
                            .tag(2)
                    }
                    Picker("輔雙跨就", selection: $selectedBetBlnMdieValue) {
                        Text("不指定")
                            .tag(0)
                        Text("包含")
                            .tag(1)
                        Text("不包含")
                            .tag(2)
                    }
                    Picker("PBL課程", selection: $selectedCrossPblValue) {
                        Text("不指定")
                            .tag(0)
                        Text("包含")
                            .tag(1)
                        Text("不包含")
                            .tag(2)
                    }
                    Picker("遠距教學課程", selection: $selectedDistanceCourseValue) {
                        Text("不指定")
                            .tag(0)
                        Text("包含")
                            .tag(1)
                        Text("不包含")
                            .tag(2)
                    }
                }
            }
            .navigationTitle("進階搜尋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("搜尋") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdvancedSearchRangePickerView: View {
    var title: String
    @Binding var selectedOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols
    @Binding var value1: Int
    @Binding var value2: Int
    
    var body: some View {
        VStack {
            LabeledContent(title, value: "")
            Picker(title, selection: $selectedOperator) {
                ForEach(Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols.allCases, id: \.hashValue) { item in
                    Text(item.getSymbols())
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Stepper(value: $value1, in: -1...10) {
                    Text("\(value1)")
                }
                if selectedOperator == .between {
                    Divider()
                    Stepper(value: $value2, in: -1...10) {
                        Text("\(value2)")
                    }
                }
            }
        }
    }
}

struct ElectionAdvancedSearchView_Previews: PreviewProvider {
    static var currentSession: CurrentSession {
        let session = CurrentSession()
        session.electionInformation_studentInformation = .init(alertText: nil, distinctIPIDCODEAlert: nil, language: nil, courseCacheKey: nil, announcementText: nil, dataSource: nil, isAuthorized: nil, crossTypeDefinitions: nil, departmentGroupDefinitions: nil, depqrtmentBuildingDefinitions: nil, departmentDefinitions: nil, generalOpDefinitions: nil, opDefinitions: nil, opStudyTypeDefinitions: nil, takeCourseList: nil, trackList: nil, registerList: nil, makeUpList: nil)
        return session
    }
    
    static var previews: some View {
        ElectionAdvancedSearchView()
            .environmentObject(currentSession)
    }
}
