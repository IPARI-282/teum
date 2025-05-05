//
//  StorageManager.swift
//  teum
//
//  Created by dream on 5/5/25.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()

    private init() {}

    func uploadNoteImage(_ imageData: Data, userId: String, noteId: String, index: Int) async throws -> String {
        let path = "notes/\(userId)/\(noteId)/image_\(index).jpg"
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(imageData, metadata: nil)
        return try await ref.downloadURL().absoluteString
    }
    
    func deleteImage(at fullURL: String) async throws {
           let ref = storage.reference(forURL: fullURL)
           try await ref.delete()
       }
}
