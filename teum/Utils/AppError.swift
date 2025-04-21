//
//  AppError.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import Foundation

// 앱 전체에서 사용할 에러 정의, 필요시 추가
enum AppError: LocalizedError {
    case authNotFound
    case firestoreUserNotFound

    // Firestore 유저 관련 에러
    case firestoreUserSaveFailed
    case firestoreUserUpdateFailed
    case firestoreUserDeleteFailed

    // Firestore 노트 관련 에러
    case firestoreNoteSaveFailed
    case firestoreNoteUpdateFailed
    case firestoreNoteDeleteFailed

    // 회원 탈퇴 관련 에러
    case accountDeletionFailed
    case invalidNoteData
    case unknown

    var errorDescription: String? {
        switch self {
        case .authNotFound:
            return "로그인 정보가 없습니다. 다시 로그인 해주세요."

        case .firestoreUserNotFound:
            return "사용자 정보를 불러오지 못했습니다."

        case .firestoreUserSaveFailed:
            return "사용자 정보를 저장하는 데 실패했습니다."
        case .firestoreUserUpdateFailed:
            return "사용자 정보를 업데이트하는 데 실패했습니다."
        case .firestoreUserDeleteFailed:
            return "사용자 정보를 삭제하는 데 실패했습니다."

        case .firestoreNoteSaveFailed:
            return "노트를 저장하는 데 실패했습니다."
        case .firestoreNoteUpdateFailed:
            return "노트를 수정하는 데 실패했습니다."
        case .firestoreNoteDeleteFailed:
            return "노트를 삭제하는 데 실패했습니다."

        case .accountDeletionFailed:
            return "회원 탈퇴 중 오류가 발생했습니다."

        case .invalidNoteData:
            return "노트 정보가 올바르지 않습니다."

        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
