//
//  ElectionDataStructures.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/2/7.
//

import Foundation

extension MyselfDefinitions {
    
    // MARK: Data Structures
    struct ElectionDataStructures {
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
                let remark: String?
                
                @DecodeToIntArray var enter3Bits: [Int]?
                @DecodeToIntArray var enter2Bits: [Int]?
                @DecodeToIntArray var enterBits: [Int]?
                @DecodeToIntArray var actionBits: [Int]?
                @DecodeToInt var snStageType: Int?
                @DecodeToInt var sn: Int?
                @DecodeToDate var beginTime: Date?
                @DecodeToDate var endTime: Date?

                private enum CodingKeys: String, CodingKey {
                    case enter3Bits = "ENTER3_BITS"
                    case enter2Bits = "ENTER2_BITS"
                    case enterBits = "ENTER_BITS"
                    case actionBits = "ACTION_BITS"
                    case snStageType = "SN_STAGE_TYPE"
                    case sn = "SN"
                    case beginTime = "BGTIME"
                    case endTime = "EDTIME"
                    case remark = "REMARK"
                }
            }
        }
        
        struct StudentBaseInformation: Codable {
            let studentsInformation: [StudentInformation]?
            
            private enum CodingKeys: String, CodingKey {
                case studentsInformation = "st_info"
            }
            
            struct StudentInformation: Codable {
                let crossBitsNameC, crossBitsNameE, deptBlnAdmin, deptNameE, idcode, stmdCOMTel, stmdCellTel, stmdCurDpt, stmdDiv, stmdDptName, stmdName, stmdRegDpt, stmdSex, stmdTypeName: String?
                let creditAssist, creditCross, creditDual, creditEduc, creditEmpl, creditMicro, creditPre, creditTotal, extraCredits, maxLimit, maxLimit0, topicCredits: Int?
                
                @DecodeToInt var creditTotalNormal: Int?
                @DecodeToIntArray var crossBits: [Int]?
                @DecodeToInt var enterBit: Int?
                @DecodeToInt var extraCreditsTotal: Int?
                @DecodeToInt var maxExtra: Int?
                @DecodeToInt var maxMark: Int?
                @DecodeToInt var mdieCreditsTotal: Int?
                @DecodeToInt var originalExtraCredits: Int?
                @DecodeToInt var stmdNew: Int?
                @DecodeToInt var surveyFinishRate: Int?
                @DecodeToInt var topicCredit: Int?
                @DecodeToInt var topicRCredit: Int?
                
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
        
        struct StudentInformation: Codable {
            let alertText, distinctIPIDCODEAlert, language, courseCacheKey, announcementText, dataSource: String?
            let isAuthorized: Bool?
            
            // Definitions
            let crossTypeDefinitions: [CrossType]?
            let departmentGroupDefinitions: [DepartmentGroup]?
            let depqrtmentBuildingDefinitions: [DepartmentBuilding]?
            let departmentDefinitions: [DepartmentType]?
            let generalOpDefinitions: [OpType]?
            let opDefinitions: [OpType]?
            let opStudyTypeDefinitions: [StudyType]?
            let systemControl: SystemControl?
            
            // Course Lists
            var takeCourseList: [CourseInformation]? // 修課清單
            var trackList: [CourseInformation]? // 追蹤清單
            var registerList: [CourseInformation]? // 登記清單
            var makeUpList: [CourseInformation]? // 遞補清單
            
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
                case opDefinitions = "op_type_get"
                case opStudyTypeDefinitions = "op_stdy_type_get"
                case registerList = "register_get"
                case systemControl = "sys_control_get"
                case takeCourseList = "take_course_get"
                case trackList = "track_get"
            }
            
            struct CrossType: Codable, Identifiable {
                let id = UUID()
                let crossType, name: String?
                let crossIdentifiers: [CrossIdentifier]?
                
                private enum CodingKeys: String, CodingKey {
                    case crossType = "CROSS_TYPE"
                    case name = "NAME"
                    case crossIdentifiers = "cross_id_get"
                }
                
                struct CrossIdentifier: Codable, Identifiable {
                    let id = UUID()
                    let crossName: String?
                    let crossCode: String?
                    
                    private enum CodingKeys: String, CodingKey {
                        case crossName = "CROSS_NAME"
                        case crossCode = "CROSS_CODE"
                    }
                }
            }
            
            struct DepartmentGroup: Codable, Identifiable {
                let id = UUID()
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
            
            struct DepartmentType: Codable, Identifiable {
                let id = UUID()
                let codName, adminDeptName, adminCode, deptBlnCod: String?
                
                private enum CodingKeys: String, CodingKey {
                    case codName = "COD_NAME"
                    case adminDeptName = "ADMIN_DEPT_NAME"
                    case adminCode = "ADMIN_CODE"
                    case deptBlnCod = "DEPT_BLN_COD"
                }
            }
            
            struct OpType: Codable, Identifiable {
                let id = UUID()
                let opType, sn, name: String?

                private enum CodingKeys: String, CodingKey {
                    case opType = "OP_TYPE"
                    case sn = "SN"
                    case name = "NAME"
                }
            }
            
            struct StudyType: Codable, Identifiable {
                let id = UUID()
                let stdyType, name: String?
                
                private enum CodingKeys: String, CodingKey {
                    case stdyType = "STDY_TYPE"
                    case name = "NAME"
                }
            }
            
            struct SystemControl: Codable {
                let nofLaw, nofHistory, nofSport, nofEngtalk, nofReligion, nofGodman: Int?
                let bgtime2, bgtime, yearTerm, edtime, edtime2: String?
                
                    enum CodingKeys: String, CodingKey {
                        case nofLaw = "NOF_LAW"
                        case nofHistory = "NOF_HISTORY"
                        case nofSport = "NOF_SPORT"
                        case bgtime2 = "BGTIME2"
                        case nofEngtalk = "NOF_ENGTALK"
                        case nofReligion = "NOF_RELIGION"
                        case nofGodman = "NOF_GODMAN"
                        case bgtime = "BGTIME"
                        case yearTerm = "YEAR_TERM"
                        case edtime = "EDTIME"
                        case edtime2 = "EDTIME2"
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
                
                let title, sn, content, typeName: String?
                let idx: Int?
                
                @DecodeToInt var onWeb: Int?
                @DecodeToInt var announcementType: Int?
                @DecodeToDate var dateBegin: Date?
                @DecodeToDate var dateEnd: Date?

                private enum CodingKeys: String, CodingKey {
                    case onWeb = "ON_WEB"
                    case announcementType = "ANN_TYPE"
                    case dateBegin = "DATE_BEG"
                    case dateEnd = "DATE_END"
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
                
                let opCode, deptName, opType, statusName, opStdyDept, itemOperator, opQuality, cname, insUser, teacher: String?
                let opCredit: Int?
                
                @DecodeToDate var updateTime: Date?
                @DecodeToStringAndRemoveTrailingSpaces var opTime123: String?
                
                private enum CodingKeys: String, CodingKey {
                    case opCode = "OP_CODE"
                    case deptName = "DEPT_NAME"
                    case opType = "OP_TYPE"
                    case updateTime = "UPDATE_TIME"
                    case opTime123 = "OP_TIME_123"
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
        struct CourseInformation: Codable, Identifiable, Hashable {
            let id = UUID()
            let deptName, opRmName1, cursCode, cname, opCode, deptCode, opStdy, opType, dataToken, opTime1, opQuality, teacher, crossName, memo1, opRmName2, opTime2, nameStatus, mgDeptCode, opStdyDept, cursLang, divCode: String?
            let beginTf: Bool?
            
            // TODO: Possible decoder implement needed
            let actionBits: String?
            let crossType: String?
            
            @DecodeToDate var updateTime: Date?
            
            @DecodeToStringAndRemoveTrailingSpaces var opRmName123: String?
            @DecodeToStringAndRemoveTrailingSpaces var opTime123: String?
            
            @DecodeToInt var allEnglish: Int?
            @DecodeToInt var autoset: Int?
            @DecodeToInt var betBln: Int?
            @DecodeToInt var betBlnB: Int?
            @DecodeToInt var betBlnMd: Int?
            @DecodeToInt var betBlnMdie: Int?
            @DecodeToInt var betBlnR: Int?
            @DecodeToInt var betDept: Int?
            @DecodeToInt var clsCap1: Int?
            @DecodeToInt var clsCap2: Int?
            @DecodeToInt var clsCap3: Int?
            @DecodeToInt var distance: Int?
            @DecodeToInt var dpDistance: Int?
            @DecodeToInt var dropAutoset: Int?
            @DecodeToInt var lastRegMan: Int?
            @DecodeToInt var man: Int?
            @DecodeToInt var moocs: Int?
            @DecodeToInt var nonStop: Int?
            @DecodeToInt var opCredit: Int?
            @DecodeToInt var openMan: Int?
            @DecodeToInt var opMan: Int?
            @DecodeToInt var opManSum: Int?
            @DecodeToInt var ord: Int?
            @DecodeToInt var ordAppend: Int?
            @DecodeToInt var remain: Int?
            @DecodeToInt var snCourseType: Int?
            @DecodeToInt var snStatus: Int?
            @DecodeToInt var typeBit: Int?
            @DecodeToInt var upperMan: Int?
            
            private enum CodingKeys: String, CodingKey {
                case actionBits = "ACTION_BITS" // 目前可使用的選課功能
                case allEnglish = "ALL_ENGLISH" // 全英語授課
                case autoset = "AUTOSET"
                case beginTf = "begin_TF"
                case betBln = "BET_BLN"
                case betBlnB = "BET_BLN_B"
                case betBlnMd = "BET_BLN_MD"
                case betBlnMdie = "BET_BLN_MDIE"
                case betBlnR = "BET_BLN_R"
                case betDept = "BET_DEPT"
                case clsCap1 = "CLS_CAP_1"
                case clsCap2 = "CLS_CAP_2"
                case clsCap3 = "CLS_CAP_3"
                case cname = "CNAME" // 課程名稱
                case crossName = "CROSS_NAME" // 學程名稱
                case crossType = "CROSS_TYPE" // 學程類別
                case cursCode = "CURS_CODE" // 課程代碼
                case cursLang = "CURS_LANG" // 授課語言
                case dataToken = "DATA_Token" // 選課操作認證碼
                case deptCode = "DEPT_CODE" // 學系班級代碼
                case deptName = "DEPT_NAME" // 學系班級名稱
                case distance = "DISTANCE" // 遠距課程
                case divCode = "DIV_CODE"
                case dpDistance = "DP_DISTANCE"
                case dropAutoset = "DROP_AUTOSET"
                case lastRegMan = "LAST_REG_MAN" // 去年登記人數
                case man = "MAN"
                case memo1 = "MEMO1" // 備注
                case mgDeptCode = "MG_DEPT_CODE" // 學系代碼
                case moocs = "MOOCS" // 微學分課程
                case nameStatus = "NAME_STATUS"
                case nonStop = "NON_STOP" // 可否停修
                case opCode = "OP_CODE" // 開課代碼
                case opCredit = "OP_CREDIT" // 學分
                case opMan = "OP_MAN"
                case opManSum = "OpManSum"
                case opQuality = "OP_QUALITY" // 全/半
                case opRmName1 = "OP_RM_NAME_1" // 上課教室1
                case opRmName123 = "OP_RM_NAME_123" // 上課教室（全部）
                case opRmName2 = "OP_RM_NAME_2" // 上課教室2
                case opStdy = "OP_STDY" // 必/選修（優先）
                case opStdyDept = "OP_STDY_DEPT" // 必/選修
                case opTime1 = "OP_TIME_1" // 上課時間1
                case opTime123 = "OP_TIME_123" // 上課時間（全部）
                case opTime2 = "OP_TIME_2" // 上課教室2
                case opType = "OP_TYPE" // 通識類別
                case openMan = "OPEN_MAN"
                case ord = "ORD"
                case ordAppend = "ORD_APPEND"
                case remain = "REMAIN"
                case snCourseType = "SN_COURSE_TYPE"
                case snStatus = "SN_STATUS"
                case teacher = "TEACHER" // 授課老師
                case typeBit = "TYPE_BIT" // 課程類別
                case updateTime = "UPDATE_TIME" // 更新時間
                case upperMan = "UPPER_MAN"
            }
        }
        
        // Used when requesting syllabus information
        struct SyllabusInfo {
            let yearTerm: String
            let opCode: String
        }

        // MARK: Course Search Request Query Structure (Defined with non-optional values)
        struct CourseSearchRequestQuery: Codable {
            let opCode, cname, crossCode, opStdy, teacher, nonStop, betDept, betBln, betBlnMdie, crossPbl, distance, deptDiv: WrappedString
            let deptCode, general, opType, opTime123: WrappedStringArray
            let opCredit, man, opManSum, remain, regMan: WrappedCompared
            let emiCourse: WrappedBool
            
            private enum CodingKeys: String, CodingKey {
                case deptCode = "DEPT_CODE" // 開課學系
                case opCode = "OP_CODE" // 課程代碼
                case cname = "CNAME" // 課程名稱
                case general = "GENERAL" // 課程類別
                case opType = "OP_TYPE" // 通識類別
                case crossCode = "CROSS_CODE" // 跨就微學程
                case opStdy = "OP_STDY" // 必/選修
                case opCredit = "OP_CREDIT" // 學分數
                case teacher = "TEACHER" // 授課教師
                case opTime123 = "OP_TIME_123" // 上課時間
                case man = "MAN" // 已選人數(含自動加選)
                case opManSum = "OpManSum" // 選課名額
                case remain = "REMAIN" // 篩選餘額
                case regMan = "REG_MAN" // 現階段登記人數
                case emiCourse = "EMI_COURSE" // 全英語課程
                case nonStop = "NON_STOP" // 停修
                case betDept = "BET_DEPT" // 跨系
                case betBln = "BET_BLN" // 跨部
                case betBlnMdie = "BET_BLN_MDIE" // 輔雙跨就
                case crossPbl = "CROSS_PBL" // PBL課程
                case distance = "DISTANCE" // 遠距教學課程
                case deptDiv = "DEPT_DIV" // 部別
            }
            
            struct WrappedBool: Codable {
                var value: Bool = false
            }
            
            struct WrappedString: Codable {
                var value: String = ""
            }
            
            struct WrappedStringArray: Codable {
                var value: [String] = []
            }
            
            struct WrappedCompared: Codable {
                var value: Int = 0
                var value2: Int = 0 // Used when between is selected
                var compare: CompareSymbols = .none
                
                // Custom encoder to convert integer to string
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery.WrappedCompared.CodingKeys.self)
                    try container.encode(compare != .none ? String(self.value) : "", forKey: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery.WrappedCompared.CodingKeys.value)
                    try container.encode(compare == .between ? String(self.value2) : "", forKey: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery.WrappedCompared.CodingKeys.value2)
                    try container.encode(self.compare.rawValue, forKey: MyselfDefinitions.ElectionDataStructures.CourseSearchRequestQuery.WrappedCompared.CodingKeys.compare)
                }
            }
            
            enum CompareSymbols: Int, Codable, CaseIterable {
                case none = 0
                case smallerThan = 1
                case equal = 2
                case biggerThan = 3
                case smallerOrEqualThan = 4
                case biggerOrEqualThan = 5
                case between = 6
                
                func getSymbols() -> String {
                    switch self {
                    case .none:
                        return ""
                    case .smallerThan:
                        return "<"
                    case .equal:
                        return "="
                    case .biggerThan:
                        return ">"
                    case .smallerOrEqualThan:
                        return "≤"
                    case .biggerOrEqualThan:
                        return "≥"
                    case .between:
                        return "~"
                    }
                }
            }
        }
        
        // Tracking response
        struct TrackingListResponse: Codable {
            let trackingList: [CourseInformation]?
            
            private enum CodingKeys: String, CodingKey {
                case trackingList = "track_get"
            }
        }
        
        // Response structure
        struct CourseSearchRequestResponse: Codable {
            let logData: Logdata?
            let courseData: [CourseInformation]?
            
            private enum CodingKeys: String, CodingKey {
                case logData = "CacheLogData"
                case courseData = "course_get"
            }
            
            struct Logdata: Codable {
                let applicationCount: Int?
                let dbCount: Int?
            }
        }
    }
}
