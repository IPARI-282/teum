//
//  PublicPrint.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import Foundation

//NSObject + Extension 으로 정의시 NSObject를 상속받는 클래스에서만 사용가능
public func pprint(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n",
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
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
