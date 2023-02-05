//
//  Election.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/19.
//

import Foundation

extension Definitions {
    // MARK: Commands
    enum ElectionCommands: String, CaseIterable {
        case st_info_get
        case stage_control_get
        case st_base_info
        case track_get
        case st_record
        case ann_get
        case course_get
        case track_insert
        case track_del
        case take_course_and_register_insert
        case take_course_and_register_del
        case login_sys_upd
        case volunteer_set
        case col_checkbox_upd
    }
    
    // MARK: Definitions
    struct ElectionDefinitions {
        enum PositionRoles: Int, CaseIterable {
            case freshmen = 1
            case currentStudents = 0
            // Divider
            case assistant = 41
            case teachingAssistant = 42
            case freshman = 11
            case sophomore = 12
            case junior = 13
            case senior = 14
            case firstYearGraduateStudent = 21
            case secondYearGraduateStudentAndAbove = 22
            case exchangeStudents = 31
            
            func getName(inChinese: Bool = false) -> String {
                switch self {
                case .freshmen:
                    return inChinese ? "新生" : "Freshmen"
                case .currentStudents:
                    return inChinese ? "舊生" : "Current Students"
                case .assistant:
                    return inChinese ? "助理" : "Assistant"
                case .teachingAssistant:
                    return inChinese ? "助教" : "Teaching Assistant"
                case .freshman:
                    return inChinese ? "大學部一年級" : "Freshman"
                case .sophomore:
                    return inChinese ? "大學部二年級" : "Sophomore"
                case .junior:
                    return inChinese ? "大學部三年級" : "Junior"
                case .senior:
                    return inChinese ? "大學部四年級(含)以上" : "Senior"
                case .firstYearGraduateStudent:
                    return inChinese ? "研究所一年級" : "First-year graduate student"
                case .secondYearGraduateStudentAndAbove:
                    return inChinese ? "研究所二年級(含)以上" : "Second-year graduate student or above"
                case .exchangeStudents:
                    return inChinese ? "交換生" : "Exchange Students"
                }
            }
        }
        
        enum CourseRoles: Int, CaseIterable {
            case departmentalProfessional = 11
            case pe_physicalEducation_militaryTraining = 21
            case basicknowledgecourses = 31
            
            func getName(inChinese: Bool = false) -> String {
                switch self {
                case .departmentalProfessional:
                    return inChinese ? "學系專業課程" : "Departmental Courses"
                case .pe_physicalEducation_militaryTraining:
                    return inChinese ? "通識體育軍訓課程" : "PE/Physical/Military Courses"
                case .basicknowledgecourses:
                    return inChinese ? "基本知能課程" : "Basic Knowledge Courses"
                }
            }
        }
        
        enum Actions: Int, CaseIterable {
            case election_add = 1
            case election_drop = 2
            case election_registration = 3
            
            func getName(inChinese: Bool = false) -> String {
                switch(self) {
                case .election_add:
                    return inChinese ? "加選" : "Add"
                case .election_drop:
                    return inChinese ? "退選" : "Drop"
                case .election_registration:
                    return inChinese ? "登記" : "Register"
                }
            }
        }
        
        enum Events: Int, CaseIterable {
            case firstStageRegistration = 11
            case secondStageRegistration = 12
            case firstStageAddDrop = 21
            case secondStageAddDrop = 22
            case thirdStageAddDrop = 23
            case screeningSettings = 31
            
            func getName(inChinese: Bool = false) -> String {
                switch(self) {
                case .firstStageRegistration:
                    return inChinese ? "第一階段登記" : "First stage registration"
                case .secondStageRegistration:
                    return inChinese ? "第二階段登記" : "Second stage registration"
                case .firstStageAddDrop:
                    return inChinese ? "第一階段選課" : "First stage add/drop"
                case .secondStageAddDrop:
                    return inChinese ? "第二階段選課" : "Second stage add/drop"
                case .thirdStageAddDrop:
                    return inChinese ? "第三階段選課" : "Third stage add/drop"
                case .screeningSettings:
                    return inChinese ? "篩選設定" : "Screening settings"
                }
            }
        }
        
        enum AnnouncementRoles: Int, CaseIterable {
            case guide = 1
            case onlineForm = 2
            case auxiliaryAndDoubleMajor = 3
            case courseAnnouncements = 4
            
            func getName(inChinese: Bool) -> String {
                switch self {
                case .guide:
                    return inChinese ? "操作說明" : "Guide"
                case .onlineForm:
                    return inChinese ? "線上表單選課" : "Online form election"
                case .auxiliaryAndDoubleMajor:
                    return inChinese ? "輔系雙主修預研生" : "Auxiliary and Double majoring"
                case .courseAnnouncements:
                    return inChinese ? "課程公告" : "Course Announcement"
                }
            }
        }
        
    }
    
    // MARK: Data structure
    struct ElectionInformation {
        // MARK: Statics
        struct StageControl: Codable {
            let dataSource, cacheKeySource: String?
            let stageEvents: [StageEvent]?
            
            private enum CodingKeys: String, CodingKey {
                case dataSource = "dataFrom"
                case cacheKeySource = "cacheKey_course_get"
                case stageEvents = "stage_control_get"
            }
            
            struct StageEvent: Codable, Identifiable, Hashable {
                let id = UUID()
                
                private let _enter3Bits, _enter2Bits, _enterBits, _actionBits, _snStageType, _sn, _begintime, _endtime: String?
                
                let remark: String?
                
                var enter3Bits: [Int]? { _enter3Bits?.toIntArray() }
                var enter2Bits: [Int]? { _enter2Bits?.toIntArray() }
                var enterBits: [Int]? { _enterBits?.toIntArray() }
                var actionBits: [Int]? { _actionBits?.toIntArray() }
                var snStageType: Int? { Int(_snStageType ?? "") ?? nil }
                var sn: Int? { Int(_sn ?? "") ?? nil }
                var beginTime: Date? {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.date(from: _begintime ?? "")
                }
                var endTime: Date? {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.date(from: _endtime ?? "")
                }

                private enum CodingKeys: String, CodingKey {
                    case _enter3Bits = "ENTER3_BITS"
                    case _enterBits = "ENTER_BITS"
                    case _snStageType = "SN_STAGE_TYPE"
                    case _actionBits = "ACTION_BITS"
                    case _sn = "SN"
                    case _begintime = "BGTIME"
                    case remark = "REMARK"
                    case _enter2Bits = "ENTER2_BITS"
                    case _endtime = "EDTIME"
                }
            }
        }
        
        struct StudentBaseInformation: Codable {
            let studentsInformation: [StudentInformation]?
            
            private enum CodingKeys: String, CodingKey {
                case studentsInformation = "st_info"
            }
            
            struct StudentInformation: Codable {
                private let _creditTotalNormal, _crossBits, _enterBit, _extraCreditsTotal, _maxExtra, _maxMark, _mdieCreditsTotal, _originalExtraCredits, _stmdNew, _surveyFinishRate, _topicCredit, _topicRCredit: String?
                
                let crossBitsNameC, crossBitsNameE, deptBlnAdmin, deptNameE, idcode, stmdCOMTel, stmdCellTel, stmdCurDpt, stmdDiv, stmdDptName, stmdName, stmdRegDpt, stmdSex, stmdTypeName: String?
                let creditAssist, creditCross, creditDual, creditEduc, creditEmpl, creditMicro, creditPre, creditTotal, extraCredits, maxLimit, maxLimit0, topicCredits: Int?
                
                var creditTotalNormal: Int? { Int(_creditTotalNormal ?? "") ?? nil }
                var crossBits: [Int]? { _crossBits?.toIntArray() }
                var enterBit: Int? { Int(_enterBit ?? "") ?? nil }
                var extraCreditsTotal: Int? { Int(_extraCreditsTotal ?? "") ?? nil }
                var maxExtra: Int? { Int(_maxExtra ?? "") ?? nil }
                var maxMark: Int? { Int(_maxMark ?? "") ?? nil }
                var mdieCreditsTotal: Int? { Int(_mdieCreditsTotal ?? "") ?? nil }
                var originalExtraCredits: Int? { Int(_originalExtraCredits ?? "") ?? nil }
                var stmdNew: Int? { Int(_stmdNew ?? "") ?? nil }
                var surveyFinishRate: Int? { Int(_surveyFinishRate ?? "") ?? nil }
                var topicCredit: Int? { Int(_topicCredit ?? "") ?? nil }
                var topicRCredit: Int? { Int(_topicRCredit ?? "") ?? nil }
                
                private enum CodingKeys: String, CodingKey {
                    // 【輔雙/學程】外加學分
                    case creditAssist = "CREDIT_ASSIST" // 輔系
                    case creditCross = "CREDIT_CROSS" // 跨領域學程
                    case creditDual = "CREDIT_DUAL" // 雙主修
                    case creditEduc = "CREDIT_EDUC" // 教育學程
                    case creditEmpl = "CREDIT_EMPL" // 就業學程
                    case creditMicro = "CREDIT_MICRO" // 微型學程
                    case creditPre = "CREDIT_PRE" // 預研生(預備研究生)
                    
                    case creditTotal = "CREDIT_TOTAL"
                    case _creditTotalNormal = "CREDIT_TOTAL_NORMAL"
                    case _crossBits = "CROSS_BITS"
                    case crossBitsNameC = "CROSS_BITS_NAME_C"
                    case crossBitsNameE = "CROSS_BITS_NAME_E"
                    case deptBlnAdmin = "DEPT_BLN_ADMIN"
                    case deptNameE = "DEPT_NAME_E"
                    case _enterBit = "ENTER_BIT"
                    case extraCredits = "EXTRA_CREDITS"
                    case _extraCreditsTotal = "EXTRA_CREDITS_TOTAL"
                    case idcode = "IDCODE"
                    case _maxExtra = "MAX_EXTRA"
                    case maxLimit = "MAX_LIMIT"
                    case maxLimit0 = "MAX_LIMIT_0"
                    case _maxMark = "MAX_MARK"
                    case _mdieCreditsTotal = "MDIE_CREDITS_TOTOAL"
                    case _originalExtraCredits = "ORIGINAL_EXTRA_CREDITS"
                    case stmdCOMTel = "STMD_COM_TEL"
                    case stmdCellTel = "STMD_CELL_TEL"
                    case stmdCurDpt = "STMD_CUR_DPT"
                    case stmdDiv = "STMD_DIV"
                    case stmdDptName = "STMD_DPT_NAME"
                    case stmdName = "STMD_NAME"
                    case _stmdNew = "STMD_NEW"
                    case stmdRegDpt = "STMD_REG_DPT"
                    case stmdSex = "STMD_SEX"
                    case stmdTypeName = "STMD_TYPE_NAME"
                    case _surveyFinishRate = "SURVEY_FINISH_RATE"
                    case _topicCredit = "TOPIC_CREDIT"
                    case topicCredits = "TOPIC_CREDITS"
                    case _topicRCredit = "TOPIC_R_CREDIT"
                }
            }
        }
        
        struct StudentInformation: Codable {
            let alertText, distinctIPIDCODEAlert, language, courseCacheKey, announcementText, dataSource: String?
            let isAuthorized: Bool?
            
            // Definitions
            let crossTypeDefinitions: [CrossType]?
            let departmentGroupDefinitions: [DepartmentGroup]?
            let depqrtmentBuildingDefinitions: [DepartmentBuilding]?
            let departmentDefinitions: [DepartmentType]?
            let generalOpDefinitions: [GeneralOpType]?
            
            // Course Lists
            let takeCourseList: [CourseInformation]? // 修課清單
            let trackList: [CourseInformation]? // 追蹤清單
            let registerList: [CourseInformation]? // 登記清單
            let makeUpList: [CourseInformation]? // 遞補清單
            
            private enum CodingKeys: String, CodingKey {
                case alertText = "alert_text"
                case announcementText = "announcement_td"
                case courseCacheKey = "cacheKey_course_get"
                case crossTypeDefinitions = "cross_type_get"
                case dataSource = "dataFrom"
                case departmentDefinitions = "department_get"
                case departmentGroupDefinitions = "dept_div"
                case depqrtmentBuildingDefinitions = "dept_bln_get"
                case distinctIPIDCODEAlert = "distinct_IP_IDCODE_alert"
                case generalOpDefinitions = "general_op_type_get"
                case isAuthorized = "is_auth_ok"
                case language
                case makeUpList = "make_up_get"
                case registerList = "register_get"
                case takeCourseList = "take_course_get"
                case trackList = "track_get"
            }
            
            struct CrossType: Codable {
                let crossType, name: String?
                let crossIdentifiers: [CrossIdentifier]?
                
                private enum CodingKeys: String, CodingKey {
                    case crossType = "CROSS_TYPE"
                    case name = "NAME"
                    case crossIdentifiers = "cross_id_get"
                }
                
                struct CrossIdentifier: Codable {
                    let crossName: String?
                    let crossCode: String?
                    
                    private enum CodingKeys: String, CodingKey {
                        case crossName = "CROSS_NAME"
                        case crossCode = "CROSS_CODE"
                    }
                }
            }
            
            struct DepartmentGroup: Codable {
                let deptDiv, sn, name: String?

                private enum CodingKeys: String, CodingKey {
                    case deptDiv = "DEPT_DIV"
                    case sn = "SN"
                    case name = "NAME"
                }
            }
            
            struct DepartmentBuilding: Codable {
                let codName, deptBlnCod: String?

                private enum CodingKeys: String, CodingKey {
                    case codName = "COD_NAME"
                    case deptBlnCod = "DEPT_BLN_COD"
                }
            }
            
            struct DepartmentType: Codable {
                let codName, adminDeptName, adminCode, deptBlnCod: String?
                
                private enum CodingKeys: String, CodingKey {
                    case codName = "COD_NAME"
                    case adminDeptName = "ADMIN_DEPT_NAME"
                    case adminCode = "ADMIN_CODE"
                    case deptBlnCod = "DEPT_BLN_COD"
                }
            }
            
            struct GeneralOpType: Codable {
                let opType, sn, name: String?

                private enum CodingKeys: String, CodingKey {
                    case opType = "OP_TYPE"
                    case sn = "SN"
                    case name = "NAME"
                }
            }
        }
        
        struct Announcement: Codable {
            let billboard: [Billboard]?
            let dataSource, cacheKeySource: String?
            
            private enum CodingKeys: String, CodingKey {
                case billboard = "billboard_get"
                case dataSource = "dataFrom"
                case cacheKeySource = "cacheKey_course_get"
            }
            
            struct Billboard: Codable, Identifiable, Hashable {
                let id = UUID()
                
                private let _onWeb, _announcementType, _dateBegin, _dateEnd: String?
                
                let title, sn, content, typeName: String?
                let idx: Int?
                
                var onWeb: Int? { Int(_onWeb ?? "") }
                var announcementType: Int? { Int(_announcementType ?? "") }
                var dateBegin: Date? {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.date(from: _dateBegin ?? "")
                }
                var endDate: Date? {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.date(from: _dateEnd ?? "")
                }

                private enum CodingKeys: String, CodingKey {
                    case _onWeb = "ON_WEB"
                    case _announcementType = "ANN_TYPE"
                    case _dateBegin = "DATE_BEG"
                    case _dateEnd = "DATE_END"
                    case title = "TITLE"
                    case sn = "SN"
                    case content = "CONTENT"
                    case idx = "IDX"
                    case typeName = "TYPE_NAME"
                }
            }
        }
        
        struct History: Codable {
            let historyList: [HistoryItem]?
            
            private enum CodingKeys: String, CodingKey {
                case historyList = "log_get"
            }
            
            struct HistoryItem: Codable, Identifiable, Hashable {
                let id = UUID()
                
                private let _updateTime, _opTime123: String?
                
                let opCode, deptName, opType, statusName, opStdyDept, itemOperator, opQuality, cname, insUser, teacher: String?
                let opCredit: Int?
                
                var updateTime: Date? {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.date(from: _updateTime ?? "")
                }
                
                var opTime123: String? {
                    var temp = _opTime123
                    while temp?.last?.isWhitespace == true { temp?.removeLast() }
                    return temp
                }
                
                private enum CodingKeys: String, CodingKey {
                    case opCode = "OP_CODE"
                    case deptName = "DEPT_NAME"
                    case opType = "OP_TYPE"
                    case _updateTime = "UPDATE_TIME"
                    case _opTime123 = "OP_TIME_123"
                    case statusName = "STATUS_NAME"
                    case opStdyDept = "OP_STDY_DEPT"
                    case opCredit = "OP_CREDIT"
                    case itemOperator = "OPERATOR"
                    case opQuality = "OP_QUALITY"
                    case cname = "CNAME"
                    case insUser = "INS_USER"
                    case teacher = "TEACHER"
                }
            }
        }
        
        // MARK: Shared
        struct CourseInformation: Codable, Identifiable {
            let id = UUID()
            let typeBit, deptName, opTime123, opRmName1, cursCode, betBln, cname, actionBits, betDept, opCode, distance, deptCode, opStdy, opType, dataToken, opTime1, opCredit, autoset, opQuality, teacher, crossName, memo1, crossType, opRmName2, opTime2, nameStatus, mgDeptCode, opRmName123, updateTime, opStdyDept: String?
            let betBlnR, betBlnMdie, opManSum, openMan, betBlnMd, remain, lastRegMan, nonStop, betBlnB, man, opMan, ord, snStatus, ordAppend, dropAutoset: Int?
            
            @StringToInt var _snCourseType: Int?
            
            @propertyWrapper
            struct StringToInt: Codable {
                var wrappedValue: Int?
                
                init(wrappedValue: Int? = nil) {
                    self.wrappedValue = wrappedValue
                }
                
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let value = try? container.decode(Int.self) {
                        wrappedValue = value
                    } else if let value = try? container.decode(String.self) {
                        wrappedValue = Int(value)
                    }
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case actionBits = "ACTION_BITS"
                case autoset = "AUTOSET"
                case betBln = "BET_BLN"
                case betBlnB = "BET_BLN_B"
                case betBlnMd = "BET_BLN_MD"
                case betBlnMdie = "BET_BLN_MDIE"
                case betBlnR = "BET_BLN_R"
                case betDept = "BET_DEPT"
                case cname = "CNAME"
                case crossName = "CROSS_NAME"
                case crossType = "CROSS_TYPE"
                case cursCode = "CURS_CODE"
                case dataToken = "DATA_Token"
                case deptCode = "DEPT_CODE"
                case deptName = "DEPT_NAME"
                case distance = "DISTANCE"
                case dropAutoset = "DROP_AUTOSET"
                case lastRegMan = "LAST_REG_MAN"
                case man = "MAN"
                case memo1 = "MEMO1"
                case mgDeptCode = "MG_DEPT_CODE"
                case nameStatus = "NAME_STATUS"
                case nonStop = "NON_STOP"
                case opCode = "OP_CODE"
                case opCredit = "OP_CREDIT"
                case opMan = "OP_MAN"
                case opManSum = "OpManSum"
                case opQuality = "OP_QUALITY"
                case opRmName1 = "OP_RM_NAME_1"
                case opRmName123 = "OP_RM_NAME_123"
                case opRmName2 = "OP_RM_NAME_2"
                case opStdy = "OP_STDY"
                case opStdyDept = "OP_STDY_DEPT"
                case opTime1 = "OP_TIME_1"
                case opTime123 = "OP_TIME_123"
                case opTime2 = "OP_TIME_2"
                case opType = "OP_TYPE"
                case openMan = "OPEN_MAN"
                case ord = "ORD"
                case ordAppend = "ORD_APPEND"
                case remain = "REMAIN"
                case _snCourseType = "SN_COURSE_TYPE"
                case snStatus = "SN_STATUS"
                case teacher = "TEACHER"
                case typeBit = "TYPE_BIT"
                case updateTime = "UPDATE_TIME"
            }
        }

    }
}
