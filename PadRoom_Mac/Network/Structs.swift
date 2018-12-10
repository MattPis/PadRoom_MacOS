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

struct SelectedParameterMessage: Codable {
    let val: Float
    let name: String
    let type: Int
}

struct RotationMessage: Codable {
    let type: Int
    let name: String
    let rotation: PowerMateDirection
    let value: Float
}

struct ResetParameterMessage: Codable {
    let type = 1
    let actionType = 0
    let name: String
}
