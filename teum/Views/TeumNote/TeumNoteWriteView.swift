//
//  TeumNoteWriteView.swift
//  teum
//
//  Created by junehee on 4/22/25.
//

import SwiftUI
import PhotosUI

struct TeumNoteWriteView: View {
    
    @State private var titleText = ""
    @State private var selectedDate = Date()
    @State private var contentText = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedUIImages: [UIImage] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleFieldView()
            datePickerView()
            contentFieldView()
            photoPickerView()
            selectedPhotoPreviewView()
            saveButton()
        }
        .padding(.top, 30)
        .padding(.horizontal, 20)
    }
    
    private func titleFieldView() -> some View {
        TextField("제목을 입력해 주세요.", text: $titleText, prompt: Text("제목을 입력해 주세요."))
            .bold()
            .font(.title2)
    }
    
    private func datePickerView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            DatePicker("날짜를 선택해 주세요.", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    
    private func contentFieldView() -> some View {
        ZStack {
            // background
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 1)
            
            // content
            TextEditor(text: $contentText)
                .background(.clear)
                .overlay(alignment: .topLeading) {
                    Text("내용을 입력해 주세요.")
                        .foregroundStyle(contentText.isEmpty ? .gray : .clear)
                        .padding(10)
                        .allowsHitTesting(false)
                }
                .border(.gray)
                .clipShape(.rect(cornerRadius: 10))
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
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .offset(x: 5, y: -5)
                    }
                }
            }
        }
    }
    
    private func saveButton() -> some View {
        Button {
            print("저장 버튼 클릭")
        } label: {
            Text("SAVE")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        
    }

}


#Preview {
    TeumNoteWriteView()
}
