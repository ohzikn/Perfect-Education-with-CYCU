//
//  Credits.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/19.
//

import Foundation

extension Definitions {
    // MARK: Data structure
    struct CreditsInformation: Codable {
        let stdTotalCredits: Int?
        let stdRealTotalCredits: Int?
        let stdFreeCredits: Int?
        let yearTerm: String?
        let stdEnglishPass: Bool?
        let stdRequiresCredits: Int?
        let stdElectiveCredits: Int?
        let stdBasicCredits: Int?
        
        let stdIdentity: [StdIdentity]?
        struct StdIdentity: Codable, Identifiable {
            let id = UUID()
            let stdId: String?
            let subShort: String?
            let subName: String?
            
            private enum CodingKeys: String, CodingKey {
                case stdId = "SUB1_ID"
                case subShort = "SUB1_SUB"
                case subName = "SUB1_SUB_NAME"
            }
        }
        
        let stdCourseList: [StdCourse]?
        struct StdCourse: Codable, Identifiable, Hashable {
            let id = UUID()
            let subjectName: String?
            let studyClass: String?
            let opCreditA: Int?
            let pKind: String?
            let passYearTerm: String?
            let opQualityA: String?
            let remoteYearTerm: String?
            let termA: String?
            let moocsYearTerm: String?
            let crossYearTerm: String?
            let pblYearTerm: String?
            let pKindName: String?
            let scoreFinal: String?
            let subjectCode: String?
            let miniatureYearTerm: String?
            let moocs2YearTerm: String?
            let courseName: String?
            let programYearTerm: String?
            let courseCode: String?
            let employmentYearTerm: String?
            let opCreditM: String?
            
            private enum CodingKeys: String, CodingKey {
                case subjectName = "CURS_NM_C_S_M"
                case studyClass = "STDY_CLASS"
                case opCreditA = "OP_CREDIT_A"
                case pKind = "P_KIND"
                case passYearTerm = "PASS_YEARTERM"
                case opQualityA = "OP_QUALITY_A"
                case remoteYearTerm = "REMOTE_YEAR_TERM"
                case termA = "TERM_A"
                case moocsYearTerm = "MOOCS_YEAR_TERM"
                case crossYearTerm = "CROSS_YEAR_TERM"
                case pblYearTerm = "PBL_YEAR_TERM"
                case pKindName = "P_KIND_NAME"
                case scoreFinal = "SCORE_FNAL"
                case subjectCode = "CURS_CODE_M"
                case miniatureYearTerm = "MINIATURE_YEAR_TERM"
                case moocs2YearTerm = "MOOCS2_YEAR_TERM"
                case courseName = "CURS_NM_C_S_A"
                case programYearTerm = "PROGRAM_YEAR_TERM"
                case courseCode = "OP_CODE_A"
                case employmentYearTerm = "EMPLOYMENT_YEAR_TERM"
                case opCreditM = "OP_CREDIT_M"
            }
        }
        
        let stdFullEnglish: [StdFullEnglish]?
        struct StdFullEnglish: Codable, Identifiable {
            let id = UUID()
            let opCode: String?
            let opCredit: String?
            let yearTerm: String?
            let courseName: String?
            let scoreFinal: String?
            
            private enum CodingKeys: String, CodingKey {
                case opCode = "OP_CODE"
                case opCredit = "OP_CREDIT"
                case yearTerm = "YEAR_TERM"
                case courseName = "CURS_NM_C_S"
                case scoreFinal = "SCORE_FNAL"
            }
        }
        
        let stdInfo: StdInfo?
        struct StdInfo: Codable {
            let userName: String?
            let userId: String?
            let departmentCode: String?
            let departmentGradeName: String?
            let typeName: String?
            
            private enum CodingKeys: String, CodingKey {
                case userName = "STMD1_NAME"
                case userId = "STMD3_ID"
                case departmentCode = "STMD3_CUR_DPT"
                case departmentGradeName = "DEPT_ABVI_C"
                case typeName = "TYPE_NAME"
            }
        }
        
        let yearTermList: [YearTermList]?
        struct YearTermList: Codable, Identifiable {
            let id = UUID()
            let yearName: Int?
            let termName: String?
            let yearTerm: Int?
            
            private enum CodingKeys: String, CodingKey {
                case yearName = "YEAR_NAME"
                case termName = "TERM_NAME"
                case yearTerm = "YEAR_TERM"
            }
        }
        
        let exceptionGeCreditsList: [ExceptionGeCreditsList]?
        struct ExceptionGeCreditsList: Codable, Identifiable {
            let id = UUID()
            let departmentCode: String?
            
            private enum CodingKeys: String, CodingKey {
                case departmentCode = "DEPT_CODE"
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case stdTotalCredits = "STD_TOTAL_CREDITS"
            case stdRealTotalCredits = "STD_REAL_TOTAL_CREDITS"
            case stdFreeCredits = "STD_FREE_CREDITS"
            case yearTerm = "YEAR_TERM"
            case stdEnglishPass = "STD_ENGLISH_PASS"
            case stdRequiresCredits = "STD_REQUIRED_CREDITS"
            case stdElectiveCredits = "STD_ELECTIVE_CREDITS"
            case stdBasicCredits = "STD_BASIC_CREDITS"
            case stdIdentity = "STD_IDENTITY"
            case stdCourseList = "STD_COURSE_LIST"
            case stdFullEnglish = "STD_FULL_ENGLISH"
            case stdInfo = "STD_INFO"
            case yearTermList = "YEAR_TERM_LIST"
            case exceptionGeCreditsList = "exception_GECredits_LIST"
        }
    }
}
