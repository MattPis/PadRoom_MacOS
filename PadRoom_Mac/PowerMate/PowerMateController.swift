//
//  PowerMateController.swift
//  PadRoom_Mac
//
//  Created by Matt on 12/3/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Foundation
import USBDeviceSwift


// PowerMate Delegate Protocol
protocol PowerMateDelegate {
    func didConnect()
    func didDisconnect()
}

class PowerMateController {
    let rfDeviceMonitor = HIDDeviceMonitor([
        HIDMonitorData(vendorId: Constants.powerMateVendorID, productId: Constants.powerMateProductID)
        ], reportSize: 8)
    
    var lastRotationStamp: TimeInterval?
    
    /// PowerMate rotation adjusts parameter selected by Wifi Client App.
    /// Parameter floating precision can very. Default = 1.0
    var selectedParam: SelectedParameterMessage? = SelectedParameterMessage()
    
    /// Create PowerMate controller
    /// parameter: d - PowerMateDelegate
    /// returns: initiated object
    init(_ d: PowerMateDelegate?) {
        delegate = d
        let rfDeviceDaemon = Thread(target: self.rfDeviceMonitor, selector:#selector(self.rfDeviceMonitor.start), object: nil)
        addNotificationObservers()
        rfDeviceDaemon.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var connectedDevice:HIDDevice?
    var delegate: PowerMateDelegate?
    
    func addNotificationObservers() {
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .HIDDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .HIDDeviceDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hidReadData), name: .HIDDeviceDataReceived, object: nil)
    }
    
    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let device:HIDDevice = nobj["device"] as? HIDDevice else {
            return
        }
        connectedDevice = device
        delegate?.didConnect()
        print("Device Connected: \(device.name)")
    }
    
    @objc func usbDisconnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let deviceId:String = nobj["id"] as? String else {
            return
        }
        
        if deviceId.isEmpty || deviceId == connectedDevice?.id {
            delegate?.didDisconnect()
            connectedDevice = nil
            print("Device disconnected: \(deviceId)")
        }
    }
    
    @objc func hidReadData(notification: Notification) {
        
        guard let data = notification.hidData() else { return }
        processHidData(data)
    }
    
    ///Procoesses device's data
    /// - parameter data: device's data
    func processHidData(_ data: Data) {
        if data[Constants.powerMateButtonIndex] == 1 {
            processButton()
        }
        else if data[Constants.powermateRotationIndex] == 1 {
            processRotation(data)
        }
    }
    
    ///Procoesses device's button click data, creates a json and sends to Lightroom
    /// - parameter data: device's data
    func processButton() {
        guard let data = encodeResetMessage() else { return }
        NetworkManager.shared.writeToLr(data)
    }
    
    ///Procoesses device's rotation data, creates a json and sends to Lightroom
    /// - parameter data: device's data
    func processRotation(_ data: Data) {
        guard let s = selectedParam else { return }
        let value = s.val * Float(HIDDevice.rotationMultiplier(previousStamp: lastRotationStamp))
        lastRotationStamp = Date().timeIntervalSinceReferenceDate
        
        let rotationData = HIDDevice.rotationFromData(data)
        guard let rotationDirection = PowerMateDirection(rawValue: rotationData) else { return }
        
        guard let json = encodeRotationMessage(r: rotationDirection, paramName: s.name, v: value) else { return }
        NetworkManager.shared.writeToLr(json)
    }
    
    func encodeResetMessage() -> Data? {
        guard let s = selectedParam else { return nil }
        let m = ResetParameterMessage(type: 1, actionType: 0, name: s.name)
        let data = try? JSONEncoder().encode(m)
        guard var d = data else { return nil }
        d.addEndOfLineSuffix()
        return d
    }
    
    func encodeRotationMessage(r: PowerMateDirection, paramName: String, v: Float) -> Data? {
        let m = PowerMateMessage(type: Constants.powerMateMessageType, paramName: paramName, rotation: r, value: v)
        var data = try? JSONEncoder().encode(m)
        data?.addEndOfLineSuffix()
        return data
    }
}

fileprivate extension HIDDevice {
    
    /// Creates PowerMate rotation multiplier based on rotation frequency
    /// - returns: rotation multiplier
   static func rotationMultiplier(previousStamp: TimeInterval?) -> Double {
        let stamp = Date().timeIntervalSinceReferenceDate
        
        guard let l = previousStamp else {
            return 1
        }
        
        let diff = stamp - l
        let rps = Constants.secondsInMinute / diff
        let m = rps / Constants.powerMaterotationRatioDivider
        let r =  m > 1 ? m : 1.0 /// multiplayer needs to be at least 1.0
        print("\(r)")
        return r
    }
    
    static func rotationFromData(_ d: Data) -> UInt8 {
        return d[Constants.powermateRotationIndex]
    }
}

fileprivate extension Notification {
    /// extracts recieved device data from notification
    func hidData() -> Data? {
        guard let obj = object as? NSDictionary else { return nil}
        return obj["data"] as? Data
    }
}

fileprivate extension Data {
    ///Adds end of line character
    mutating func addEndOfLineSuffix() {
        guard let d = "\n".data(using: .utf8) else { return }
        append(d)
    }
}
