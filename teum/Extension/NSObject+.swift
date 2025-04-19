//
//  NSObject+.swift
//  teum
//
//  Created by dream on 4/19/25.
//

import Foundation

/// 출력위치, 시간 표시 출력 함수
extension NSObject {
     public func tprint(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, function: String = #function) {
        #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        let filePath = URL(fileURLWithPath: file).lastPathComponent
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_KR")
        format.dateFormat = "MM/dd a hh:mm:ss"
        
        let logMessage = "\n[\(format.string(from: Date()))] <\(filePath):(\(line)) \(function)> : \n\(output)"
        
        print("DEBUG: \(logMessage)", terminator: terminator)
        #endif
    }
}
