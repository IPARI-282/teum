//
//  FireStoreManager.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FireStoreManager {
    static let shared = FireStoreManager()

    private let db = Firestore.firestore()

    private init() { }

    // MARK: - 사용자 등록, 최초 로그인시 Firestore에 사용자 등록
    func saveUser(name: String, email: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.authNotFound
        }

        let ref = db.collection("Users").document(uid)
        let snapshot = try await ref.getDocument()

        guard !snapshot.exists else {
            pprint("⚠️ 이미 등록된 사용자입니다.")
            return
        }

        let user = FirestoreUser(
            id: uid,
            name: name,
            email: email,
            profileImageURL: nil
        )

        do {
            try ref.setData(from: user)
            pprint("✅ 사용자 저장 완료")
        } catch {
            throw AppError.firestoreUserSaveFailed
        }
    }

    // MARK: - 사용자 프로필 이미지 업데이트
    func updateUserProfileImage(uid: String, imageURL: String) async throws {
        do {
            try await db.collection("Users").document(uid).updateData(["profileImageURL": imageURL])
            pprint("🖼️ 프로필 이미지 업데이트 완료")
        } catch {
            throw AppError.firestoreUserUpdateFailed
        }
    }

    // MARK: - 사용자 조회
    func fetchUser(by uid: String) async throws -> FirestoreUser? {
        let snapshot = try await db.collection("Users").document(uid).getDocument()
        guard snapshot.exists else {
            throw AppError.firestoreUserNotFound
        }
        return try snapshot.data(as: FirestoreUser.self)
    }

    // MARK: - 노트 추가
    func addNote(_ note: Note) async throws {
        do {
            try db.collection("Notes").addDocument(from: note)
        } catch {
            throw AppError.firestoreNoteSaveFailed
        }
    }

    // MARK: - 내 노트 조회
    func fetchMyNotes() async throws -> [Note] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.authNotFound
        }

        let snapshot = try await db.collection("Notes")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap {
            try $0.data(as: Note.self)
        }
    }
    
    // MARK: - 커뮤니티 노트 조회 (isPublic = true)
    func fetchPublicNotes() async throws -> [Note] {
        let snapshot = try await db.collection("Notes")
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap {
            try $0.data(as: Note.self)
        }
    }

    // MARK: - 노트 수정
    func updateNote(noteId: String, with data: [String: Any]) async throws {
        do {
            try await db.collection("Notes").document(noteId).updateData(data)
        } catch {
            throw AppError.firestoreNoteUpdateFailed
        }
    }

    // MARK: - 노트 삭제
    func deleteNote(noteId: String) async throws {
        do {
            try await db.collection("Notes").document(noteId).delete()
        } catch {
            throw AppError.firestoreNoteDeleteFailed
        }
    }

    // MARK: - 유저 정보 삭제
    private func deleteUserDocument(uid: String) async throws {
        do {
            try await db.collection("Users").document(uid).delete()
        } catch {
            throw AppError.firestoreUserDeleteFailed
        }
    }

    // MARK: - 노트 전체 삭제
    private func deleteAllNotes(for uid: String) async throws {
        let snapshot = try await db.collection("Notes")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()

        for document in snapshot.documents {
            do {
                try await document.reference.delete()
            } catch {
                throw AppError.firestoreNoteDeleteFailed
            }
        }
    }

    // MARK: - 회원 탈퇴
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.authNotFound
        }
        let uid = user.uid

        do {
            try await deleteUserDocument(uid: uid)
            try await deleteAllNotes(for: uid)
            try await user.delete()
            pprint("✅ 회원 탈퇴 완료")
        } catch {
            throw AppError.accountDeletionFailed
        }
    }
}
