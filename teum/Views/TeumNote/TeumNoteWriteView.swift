//
//  TeumNoteWriteView.swift
//  teum
//
//  Created by junehee on 4/22/25.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct TeumNoteWriteView: View {
    
    @State private var titleText = ""
    @State private var selectedDate = Date()
    @State private var selectedDistrict: SeoulDistrict = .gangnam
    @State private var socialBattery: Double = 50
    @State private var contentText = ""
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedUIImages: [UIImage] = []
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    enum SeoulDistrict: String, CaseIterable {
        case gangnam
        case gangdong
        case gangbuk
        case gangseo
        case gwanak
        case gwangjin
        case guro
        case geumcheon
        case nowon
        case dobong
        case dongdaemun
        case dongjak
        case mapo
        case seodaemun
        case seocho
        case seongdong
        case seongbuk
        case songpa
        case yangcheon
        case yeongdeungpo
        case yongsan
        case eunpyeong
        case jongno
        case jung
        case jungnang

        var koreanName: String {
            switch self {
            case .gangnam: return "강남구"
            case .gangdong: return "강동구"
            case .gangbuk: return "강북구"
            case .gangseo: return "강서구"
            case .gwanak: return "관악구"
            case .gwangjin: return "광진구"
            case .guro: return "구로구"
            case .geumcheon: return "금천구"
            case .nowon: return "노원구"
            case .dobong: return "도봉구"
            case .dongdaemun: return "동대문구"
            case .dongjak: return "동작구"
            case .mapo: return "마포구"
            case .seodaemun: return "서대문구"
            case .seocho: return "서초구"
            case .seongdong: return "성동구"
            case .seongbuk: return "성북구"
            case .songpa: return "송파구"
            case .yangcheon: return "양천구"
            case .yeongdeungpo: return "영등포구"
            case .yongsan: return "용산구"
            case .eunpyeong: return "은평구"
            case .jongno: return "종로구"
            case .jung: return "중구"
            case .jungnang: return "중랑구"
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("오늘의 혼놀 기록")) {
                    TextField("제목", text: $titleText)
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                    districtPickerView()
                }
                Section {
                    contentFieldView()
                }
                Section(header: Text("오늘의 소셜 배터리 점수는?")) {
                    Slider(value: $socialBattery, in: 0...100, step: 1) {
                        Text("소셜 배터리")
                    }
                    Text("\(Int(socialBattery))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            HStack {
                Spacer()
                photoPickerView()
            }
            .padding(.trailing)
            selectedPhotoPreviewView()
            saveButton()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func titleFieldView() -> some View {
        TextField("제목", text: $titleText, prompt: Text("오늘 혼놀은 어떠셨어요?"))
            .bold()
            .font(.title2)
    }
    
    private func datePickerView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
        }
    }
    
    private func districtPickerView() -> some View {
        Picker("장소", selection: $selectedDistrict) {
            ForEach(SeoulDistrict.allCases, id: \.self) { district in
                Text(district.koreanName).tag(district.rawValue)
            }
        }
        .pickerStyle(.menu)
        .foregroundStyle(.black)
    }
    
    private func contentFieldView() -> some View {
        TextEditor(text: $contentText)
            .overlay(alignment: .topLeading) {
                Text("내용을 입력해 주세요.")
                    .foregroundStyle(contentText.isEmpty ? .gray : .clear)
                    .padding(12)
                    .allowsHitTesting(false)
            }
    }
    
    private func photoPickerView() -> some View {
        Group {
            if selectedUIImages.count < 5 {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 5,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .onChange(of: selectedPhotos) {
                    Task {
                        selectedUIImages = []
                        for item in selectedPhotos {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedUIImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func selectedPhotoPreviewView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(selectedUIImages.enumerated()), id: \.element) { idx, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)

                        Button(action: {
                            selectedUIImages.remove(at: idx)
                            selectedPhotos.remove(at: idx)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .offset(x: -5, y: 5)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func saveButton() -> some View {
        Button {
            Task {
                await saveNoteToFirestore()
            }
        } label: {
            Text("기록하기")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.deepNavyBlue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private func saveNoteToFirestore() async {
        let uid = UserDefaultsManager.shared.userId

        do {
            try await FireStoreManager.shared.saveTestUser()
        } catch {
            alertMessage = "유저 저장 실패: \(error.localizedDescription)"
            showAlert = true
            return
        }

        let note = Note(
            userId: uid,
            title: titleText,
            date: selectedDate,
            socialBattery: socialBattery,
            district: selectedDistrict.rawValue,
            content: contentText,
            imagePaths: [],  // TODO: 이미지 어떻게 저장할건지 논의 필요
            isPublic: UserDefaultsManager.shared.isTeumNotePublic,
            createdAt: Date(),
        )

        do {
            try await FireStoreManager.shared.addNote(note)
            alertMessage = "노트 저장 성공! (userId: \(uid))"
            UserDefaultsManager.shared.isTeumNotePublic = true  // 기본값으로 다시 설정
        } catch {
            alertMessage = "노트 저장 실패: \(error.localizedDescription)"
        }

        showAlert = true
    }

}


#Preview {
    TeumNoteWriteView()
}
