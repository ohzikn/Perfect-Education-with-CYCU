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
    @State var selectedDepartmentIds = Set<String>()
    @State var selectedOpIds = Set<String>()
    @State var selectedGeneralOpIds = Set<String>()
    
    
    @State var selectedDepartmentGroupId: String = ""
    @State var selectedCrossId: UUID?
    @State var selectedStudyTypeId: String = ""
    @State var emiCourseToggle: Bool = false
    
    @State var opCode_Entry = ""
    @State var cName_Entry = ""
    @State var teacher_Entry = ""
    
    @State var selectedCreditsOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedCreditsValue1: Int = 0
    @State var selectedCreditsValue2: Int = 0
    
    @State var selectedManCurrentOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManCurrentValue1: Int = 0
    @State var selectedManCurrentValue2: Int = 0
    
    @State var selectedManSumOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManSumValue1: Int = 0
    @State var selectedManSumValue2: Int = 0
    
    @State var selectedManRemainOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManRemainValue1: Int = 0
    @State var selectedManRemainValue2: Int = 0
    
    @State var selectedManRegisterOperator: Definitions.ElectionDataStructures.CourseSearchRequestQuery.CompareSymbols = .none
    @State var selectedManRegisterValue1: Int = 0
    @State var selectedManRegisterValue2: Int = 0
    
    @State var selectedNonStopValue: Int = 0
    @State var selectedBetDeptValue: Int = 0
    @State var selectedBetBlnValue: Int = 0
    @State var selectedBetBlnMdieValue: Int = 0
    @State var selectedCrossPblValue: Int = 0
    @State var selectedDistanceCourseValue: Int = 0
    
    private func getCrossInfo(_ id: UUID?) -> Definitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier? {
        var result: Definitions.ElectionDataStructures.StudentInformation.CrossType.CrossIdentifier?
        
        if let id, let definitions = currentSession.electionInformation_studentInformation?.crossTypeDefinitions {
            definitions.forEach { crossType in
                if let target = crossType.crossIdentifiers?.first(where: { $0.id == id }) {
                    result = target
                }
            }
        }
        return result
    }
    
    init(inheritenced: State<String>) {
        _cName_Entry = inheritenced
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("快速查詢") {
                    Button("本班所有課程") {
                        Task {
                            await currentSession.requestElection(filterQuery: nil, filterType: 1)
                        }
                        dismiss()
                    }
                    Button("本系本年級所有課程") {
                        Task {
                            await currentSession.requestElection(filterQuery: nil, filterType: 2)
                        }
                        dismiss()
                    }
                    Button("本系所有課程") {
                        Task {
                            await currentSession.requestElection(filterQuery: nil, filterType: 3)
                        }
                        dismiss()
                    }
                }
                Section("進階搜尋") {
                    if let studentInfo = currentSession.electionInformation_studentInformation {
                        Group {
                            NavigationLink {
                                ElectionSearchDepartmentIdView(selectedDepartmentIds: _selectedDepartmentIds)
                            } label: {
                                HStack {
                                    Text("開課學系")
                                    Spacer()
                                    Text(selectedDepartmentIds.count != 0 ? "\(selectedDepartmentIds.count)個項目" : "不指定")
                                        .foregroundColor(.secondary)
                                }
                            }
                            Picker("部別", selection: $selectedDepartmentGroupId) {
                                if let definitions = studentInfo.departmentGroupDefinitions {
                                    Text("不指定")
                                        .tag("")
                                    ForEach(definitions) { item in
                                        Text(item.name ?? "-")
                                            .tag(item.deptDiv ?? "")
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
                        }
                        Group {
                            NavigationLink {
                                ElectionSearchOpIdView(selectedOpIds: _selectedOpIds)
                            } label: {
                                HStack {
                                    Text("通識類別")
                                    Spacer()
                                    Text(selectedOpIds.count != 0 ? "\(selectedOpIds.count)個項目" : "不指定")
                                        .foregroundColor(.secondary)
                                }
                            }
                            NavigationLink {
                                ElectionSearchGeneralOpIdView(selectedGeneralOpIds: _selectedGeneralOpIds)
                            } label: {
                                HStack {
                                    Text("課程類別")
                                    Spacer()
                                    Text(selectedGeneralOpIds.count != 0 ? "\(selectedGeneralOpIds.count)個項目" : "不指定")
                                        .foregroundColor(.secondary)
                                }
                            }
                            NavigationLink {
                                ElectionSearchCrossIdView(selectedCrossId: _selectedCrossId)
                            } label: {
                                HStack {
                                    Text("跨就微學程")
                                    Spacer()
                                    Text(getCrossInfo(selectedCrossId)?.crossName ?? "不指定")
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Group {
                            Picker("必/選修", selection: $selectedStudyTypeId) {
                                if let definitions = studentInfo.opStudyTypeDefinitions {
                                    Text("不指定")
                                        .tag("")
                                    ForEach(definitions) { item in
                                        Text(item.name ?? "-")
                                            .tag(item.name ?? "")
                                    }
                                }
                            }
                            AdvancedSearchRangePickerView(title: "學分數", selectedOperator: $selectedCreditsOperator, value1: $selectedCreditsValue1, value2: $selectedCreditsValue2)
                            LabeledContent("授課教師") {
                                TextField("選填", text: $teacher_Entry)
                                    .multilineTextAlignment(.trailing)
                            }
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
                        Group {
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
                }
            }
            .navigationTitle("搜尋選項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("搜尋") {
                        let query: Definitions.ElectionDataStructures.CourseSearchRequestQuery =
                            .init(opCode: .init(value: opCode_Entry),
                                  cname: .init(value: cName_Entry),
                                  crossCode: .init(value: getCrossInfo(selectedCrossId)?.crossCode ?? ""),
                                  opStdy: .init(value: selectedStudyTypeId),
                                  teacher: .init(value: teacher_Entry),
                                  nonStop: .init(value: selectedNonStopValue == 0 ? "" : String(selectedNonStopValue)),
                                  betDept: .init(value: selectedBetDeptValue == 0 ? "" : String(selectedBetDeptValue)),
                                  betBln: .init(value: selectedBetBlnValue == 0 ? "" : String(selectedBetBlnValue)),
                                  betBlnMdie: .init(value: selectedBetBlnMdieValue == 0 ? "" : String(selectedBetBlnMdieValue)),
                                  crossPbl: .init(value: selectedCrossPblValue == 0 ? "" : String(selectedCrossPblValue)),
                                  distance: .init(value: selectedDistanceCourseValue == 0 ? "" : String(selectedDistanceCourseValue)),
                                  deptDiv: .init(value: selectedDepartmentGroupId),
                                  deptCode: .init(value: Array(selectedDepartmentIds)),
                                  general: .init(value: Array(selectedGeneralOpIds)),
                                  opType: .init(value: Array(selectedOpIds)),
                                  opTime123: .init(), // NOT IMPLEMENTED
                                  opCredit: .init(value: selectedCreditsValue1, value2: selectedCreditsValue2, compare: selectedCreditsOperator),
                                  man: .init(value: selectedManCurrentValue1, value2: selectedManCurrentValue2, compare: selectedManCurrentOperator),
                                  opManSum: .init(value: selectedManSumValue1, value2: selectedManSumValue2, compare: selectedManSumOperator),
                                  remain: .init(value: selectedManRemainValue1, value2: selectedManRemainValue2, compare: selectedManRemainOperator),
                                  regMan: .init(value: selectedManRegisterValue1, value2: selectedManRegisterValue2, compare: selectedManRegisterOperator),
                                  emiCourse: .init(value: emiCourseToggle))
                        Task {
                            await currentSession.requestElection(filterQuery: query)
                        }
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
                if selectedOperator != .none {
                    Stepper(value: $value1, in: 0...10) {
                        Text("\(value1)")
                    }
                }
                if selectedOperator == .between {
                    Divider()
                    Stepper(value: $value2, in: 0...10) {
                        Text("\(value2)")
                    }
                }
            }
        }
    }
}

struct ElectionSearchDepartmentIdView: View {
    @EnvironmentObject var currentSession: CurrentSession
    @State var selectedDepartmentIds: Set<String>
    
    init(selectedDepartmentIds: State<Set<String>>) {
        self._selectedDepartmentIds = selectedDepartmentIds
    }
    
    var body: some View {
        List(selection: $selectedDepartmentIds) {
            if let definitions = currentSession.electionInformation_studentInformation?.departmentDefinitions {
                let groupedDefinitions = Dictionary(grouping: definitions, by: \.codName)
                let sortedDefinitions = groupedDefinitions.keys.sorted(by: { ($0 ?? "").localizedStandardCompare($1 ?? "") == .orderedAscending })
                ForEach(sortedDefinitions, id: \.?.hashValue) { groupItem in
                    Section(groupItem ?? "-") {
                        ForEach(groupedDefinitions[groupItem] ?? []) { item in
                            Text(item.adminDeptName ?? "-")
                                .tag(item.adminCode ?? "")
                        }
                    }
                }
            }
        }
        .navigationTitle("開課學系")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
    }
}

struct ElectionSearchOpIdView: View {
    @EnvironmentObject var currentSession: CurrentSession
    @State var selectedOpIds: Set<String>
    
    init(selectedOpIds: State<Set<String>>) {
        self._selectedOpIds = selectedOpIds
    }
    
    var body: some View {
        List(selection: $selectedOpIds) {
            if let definitions = currentSession.electionInformation_studentInformation?.opDefinitions {
                ForEach(definitions) { item in
                    Text(item.name ?? "-")
                        .tag(item.name ?? "")
                }
            }
        }
        .navigationTitle("通識類別")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
    }
}

struct ElectionSearchGeneralOpIdView: View {
    @EnvironmentObject var currentSession: CurrentSession
    @State var selectedGeneralOpIds: Set<String>
    
    init(selectedGeneralOpIds: State<Set<String>>) {
        self._selectedGeneralOpIds = selectedGeneralOpIds
    }
    
    var body: some View {
        List(selection: $selectedGeneralOpIds) {
            if let definitions = currentSession.electionInformation_studentInformation?.generalOpDefinitions {
                ForEach(definitions) { item in
                    Text(item.name ?? "-")
                        .tag(item.name ?? "")
                }
            }
        }
        .navigationTitle("課程類別")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, .constant(.active))
    }
}

struct ElectionSearchCrossIdView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var currentSession: CurrentSession
    @State var selectedCrossId: UUID?
    
    init(selectedCrossId: State<UUID?>) {
        self._selectedCrossId = selectedCrossId
    }
    
    var body: some View {
        List(selection: $selectedCrossId) {
            if let definitions = currentSession.electionInformation_studentInformation?.crossTypeDefinitions {
                Section {
                    HStack {
                        Text("不指定")
                            .tag(nil as UUID?)
                        Spacer()
                        if selectedCrossId == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                ForEach(definitions) { groupItem in
                    Section(groupItem.name ?? "-") {
                        if let items = groupItem.crossIdentifiers {
                            ForEach(items) { item in
                                HStack {
                                    Text(item.crossName ?? "-")
                                    Spacer()
                                    if selectedCrossId == item.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .tag(item.id as UUID?)
                                .onAppear {
                                    UITableViewCell.appearance().selectionStyle = .none
                                }
                            }
                        }
                    }
                }
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("跨就微學程")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedCrossId) { _ in
            dismiss()
        }
    }
}

struct ElectionAdvancedSearchView_Previews: PreviewProvider {
    @State static var dummyString = ""
    static var currentSession: CurrentSession {
        let session = CurrentSession()
        session.electionInformation_studentInformation = .init(alertText: nil, distinctIPIDCODEAlert: nil, language: nil, courseCacheKey: nil, announcementText: nil, dataSource: nil, isAuthorized: nil, crossTypeDefinitions: nil, departmentGroupDefinitions: nil, depqrtmentBuildingDefinitions: nil, departmentDefinitions: nil, generalOpDefinitions: nil, opDefinitions: nil, opStudyTypeDefinitions: nil, systemControl: nil, takeCourseList: nil, trackList: nil, registerList: nil, makeUpList: nil)
        return session
    }
    
    static var previews: some View {
        ElectionAdvancedSearchView(inheritenced: _dummyString)
            .environmentObject(currentSession)
    }
}
