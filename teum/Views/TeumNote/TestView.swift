//
//  TestView.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import SwiftUI
import FirebaseFirestore

/*
 teum구글 계정으로 로그인후 해당 링크 연결시 FireStore 데이터베이스 확인 가능
 https://console.firebase.google.com/project/teum-1d047/firestore/databases/-default-/data/~2FUsers~2Ftest-user?hl=ko&fb_gclid=CjwKCAjwk43ABhBIEiwAvvMEB_j08nLbdH75G5DBExUK3gjMApYDal1KAA9ql8CpLg8sgJf1UTKObhoC8_kQAvD_BwE
 */

struct FireStoreTestView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var placeName: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var socialBattery: Double = 50
    @State private var selectedDate: Date = Date()
    @State private var isPublic: Bool = true

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("제목", text: $title)
                    TextField("내용", text: $content)
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                    Toggle("커뮤니티 공개", isOn: $isPublic)
                }

                Section(header: Text("장소")) {
                    TextField("장소 이름", text: $placeName)
                    TextField("위도", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("경도", text: $longitude)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("소셜 배터리")) {
                    Slider(value: $socialBattery, in: 0...100, step: 1) {
                        Text("소셜 배터리")
                    }
                    Text("\(Int(socialBattery))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Button("노트 저장") {
                    Task {
                        await saveNote()
                    }
                }
            }
            .navigationTitle("테스트 노트 작성")
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveNote() async {
        let uid = "test-user"

        do {
            try await FireStoreManager.shared.saveTestUser()
        } catch {
            alertMessage = "유저 저장 실패: \(error.localizedDescription)"
            showAlert = true
            return
        }

        guard let lat = Double(latitude), let lng = Double(longitude) else {
            alertMessage = "위도/경도를 올바르게 입력해주세요."
            showAlert = true
            return
        }

        let note = Note(
            id: nil,
            userId: uid,
            title: title,
            date: selectedDate,
            socialBattery: Int(socialBattery),
            placeName: placeName,
            latitude: lat,
            longitude: lng,
            content: content,
            imagePaths: [],
            isPublic: isPublic,
            createdAt: Date(),
            updatedAt: nil
        )

        do {
            try await FireStoreManager.shared.addNote(note)
            alertMessage = "노트 저장 성공! (userId: \(uid))"
        } catch {
            alertMessage = "노트 저장 실패: \(error.localizedDescription)"
        }

        showAlert = true
    }
}

extension FireStoreManager {
    // 아직 로그인 쪽 연결이 되지 않아 테스트용 User Collection과 User 저장 로직
    func saveTestUser() async throws {
        let testUid = "test-user"

        let ref = Firestore.firestore().collection("Users").document(testUid)
        let snapshot = try await ref.getDocument()

        guard !snapshot.exists else {
            pprint("⚠️ 테스트 유저 이미 존재")
            return
        }

        let user = FirestoreUser(
            id: testUid,
            name: "테스트 계정",
            email: "test@example.com",
            profileImageURL: nil
        )

        try ref.setData(from: user)
        pprint("✅ 테스트 유저 저장 완료")
    }
}
