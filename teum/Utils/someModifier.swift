//
//  someModifier.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct SomeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
}
