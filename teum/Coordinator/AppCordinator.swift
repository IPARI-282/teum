//
//  AppCordinator.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import Foundation

/// App의 전체 화면 전환 및 내비게이션 흐름을 제어하는 Coordinator입니다.
final class AppCoordinator<T: Hashable>: ObservableObject {
    @Published var paths: [T] = []
    @Published var presentSheet: T?
    @Published var presentFullScreen: T?
    @Published var rootDestination: T?

    func push(_ path: T) {
        paths.append(path)
    }

    func pop() {
        paths.removeLast()
    }

    func pop(to: T) {
        guard let found = paths.firstIndex(where: { $0 == to }) else { return }
        let numToPop = (found..<paths.endIndex).count - 1
        paths.removeLast(numToPop)
    }

    func popToRoot() {
        paths.removeAll()
    }

    func changeRootView(to destination: T) {
        paths.removeAll()
        presentSheet = nil
        presentFullScreen = nil
        rootDestination = destination
        paths.append(rootDestination ?? destination)
    }

    func present(sheet: T) {
        presentSheet = sheet
    }

    func presentFullScreen(_ cover: T) {
        presentFullScreen = cover
    }

    func dismissSheet() {
        presentSheet = nil
    }

    func dismissFullScreen() {
        presentFullScreen = nil
    }

    func clearAllStack() {
        paths.removeAll()
    }
}

///  화면 정의
enum Destination: Hashable {
    case login
    case lookingForTeum
    case community
    case teumNote
    case TeumNoteWrite
    case myPage
}
