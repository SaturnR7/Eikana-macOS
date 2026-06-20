//
//  KeyCode.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Carbon

enum KeyCode {
    // Physical Key Code
    enum Physical: Int64 {
        case leftCommand = 0x37
        case rightCommand = 0x36

//        func 
    }

    // Input Source Code
    enum Language: CGKeyCode {
        case english = 0x66 // eisu
        case japanese = 0x68 // kana
    }
}
