//
//  Constants.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/23/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Cocoa

class Constants {
    public static let defaultPort: UInt16 = 6788
    public static let defaultReadTimeOut: Double = 9000
    public static let defaultWriteTimeOut: Double = -1
    public static let LRSendPort: UInt16 = 58763
    public static let LRReceivePort: UInt16 = 58764
    
    static let powerMateVendorID = 0x077d
    static let powerMateProductID = 0x0410
    static let powerMateMessageType = 4
    static let powermateRotationIndex = 1
    static let powerMateButtonIndex = 0
    static let powerMaterotationRatioDivider = 1000.0
    
    static let secondsInMinute = 60.0

}
