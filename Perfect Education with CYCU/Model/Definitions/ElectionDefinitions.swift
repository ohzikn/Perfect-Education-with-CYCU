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
}
