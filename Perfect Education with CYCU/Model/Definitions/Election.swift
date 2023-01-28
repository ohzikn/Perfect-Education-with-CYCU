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
                    return inChinese ? "系統操作說明" : "Guide"
                case .onlineForm:
                    return inChinese ? "線上表單選課作業專區" : "Online form election"
                case .auxiliaryAndDoubleMajor:
                    return inChinese ? "輔系雙主修預研生專區" : "Auxiliary and Double majoring"
                case .courseAnnouncements:
                    return inChinese ? "課程公告" : "Course Announcement"
                }
            }
        }
    }
    
    // MARK: Data structure
    struct ElectionInformation {
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
                var snStageType: Int? { Int(_snStageType ?? "") ?? 0 }
                var sn: Int? { Int(_sn ?? "") ?? 0 }
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
                let creditTotalNormal, crossBits, crossBitsNameC, crossBitsNameE, deptBlnAdmin, deptNameE, enterBit, extraCreditsTotal, idcode, maxExtra, maxMark, mdieCreditsTotal, originalExtraCredits, stmdCOMTel, stmdCellTel, stmdCurDpt, stmdDiv, stmdDptName, stmdName, stmdNew, stmdRegDpt, stmdSex, stmdTypeName, surveyFinishRate, topicCredit, topicRCredit: String?
                let creditAssist, creditCross, creditDual, creditEduc, creditEmpl, creditMicro, creditPre, creditTotal, extraCredits, maxLimit, maxLimit0, topicCredits: Int?
                
                private enum CodingKeys: String, CodingKey {
                    case creditAssist = "CREDIT_ASSIST"
                    case creditCross = "CREDIT_CROSS"
                    case creditDual = "CREDIT_DUAL"
                    case creditEduc = "CREDIT_EDUC"
                    case creditEmpl = "CREDIT_EMPL"
                    case creditMicro = "CREDIT_MICRO"
                    case creditPre = "CREDIT_PRE"
                    case creditTotal = "CREDIT_TOTAL"
                    case creditTotalNormal = "CREDIT_TOTAL_NORMAL"
                    case crossBits = "CROSS_BITS"
                    case crossBitsNameC = "CROSS_BITS_NAME_C"
                    case crossBitsNameE = "CROSS_BITS_NAME_E"
                    case deptBlnAdmin = "DEPT_BLN_ADMIN"
                    case deptNameE = "DEPT_NAME_E"
                    case enterBit = "ENTER_BIT"
                    case extraCredits = "EXTRA_CREDITS"
                    case extraCreditsTotal = "EXTRA_CREDITS_TOTAL"
                    case idcode = "IDCODE"
                    case maxExtra = "MAX_EXTRA"
                    case maxLimit = "MAX_LIMIT"
                    case maxLimit0 = "MAX_LIMIT_0"
                    case maxMark = "MAX_MARK"
                    case mdieCreditsTotal = "MDIE_CREDITS_TOTOAL"
                    case originalExtraCredits = "ORIGINAL_EXTRA_CREDITS"
                    case stmdCOMTel = "STMD_COM_TEL"
                    case stmdCellTel = "STMD_CELL_TEL"
                    case stmdCurDpt = "STMD_CUR_DPT"
                    case stmdDiv = "STMD_DIV"
                    case stmdDptName = "STMD_DPT_NAME"
                    case stmdName = "STMD_NAME"
                    case stmdNew = "STMD_NEW"
                    case stmdRegDpt = "STMD_REG_DPT"
                    case stmdSex = "STMD_SEX"
                    case stmdTypeName = "STMD_TYPE_NAME"
                    case surveyFinishRate = "SURVEY_FINISH_RATE"
                    case topicCredit = "TOPIC_CREDIT"
                    case topicCredits = "TOPIC_CREDITS"
                    case topicRCredit = "TOPIC_R_CREDIT"
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
    }
}
