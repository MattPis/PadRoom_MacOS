//
//  StatusView.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/27/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Cocoa

class StatusDetail: NSView, NetworkManagerDelegate {
    
    @IBOutlet weak var ipAddressLabel: NSTextField!
    @IBOutlet weak var iPadLabel: NSTextField!
    @IBOutlet weak var lightroomLabel: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NetworkManager.shared.delegate = self
        updateUi()
    }
    
    func updateUi() {
        ipAddressLabel.stringValue = ipAddressText()
    }
    
    func ipAddressText() -> String {
        let ip = NetworkManager.ipAddress()
        return "IP: \(ip ?? "Uknnown IP Address")"
    }
    
    ///MARK: - NetworkManager Delegate
    func clientsCountHasChanged(_ count: Int) {
        iPadLabel.stringValue = count == 0
            ? "iPad: Not Connected"
            : "iPad: Connected"
    }
    
    func lrConnectionHasChanged(_ connected: Bool) {
        lightroomLabel.stringValue = connected
            ? "Lightroom: Connected"
            : "Lightroom: Not Connected"
    }
    
}
