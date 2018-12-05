//
//  Structs.swift
//  PadRoom_Mac
//
//  Created by Matt on 12/4/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Foundation

public enum PowerMateDirection: UInt8, Codable {
    case left = 255
    case right = 1
}

struct PowerMateMessage: Encodable {
    let type: Int
    let paramName: String
    let rotation: PowerMateDirection
    let value: Float
}

struct SelectedParameterMessage: Codable {
    let val: Float = 0.01
    let name: String = "Exposure"
}

struct ResetParameterMessage: Codable {
    let type: Int
    let actionType: Int
    let name: String
}
