//
//  StatusView.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/27/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Cocoa

class StatusDetail: NSView, NetworkManagerDelegate, PowerMateDelegate {
   
    @IBOutlet weak var ipAddressLabel: NSTextField!
    @IBOutlet weak var iPadLabel: NSTextField!
    @IBOutlet weak var lightroomLabel: NSTextField!
    @IBOutlet weak var powerMateLabel: NSTextField!
    
    var pmController: PowerMateController?

    override func awakeFromNib() {
        super.awakeFromNib()
        NetworkManager.shared.delegate = self
        pmController = PowerMateController(self)
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
    
    func DidRecieveSelectedParameter(_ param: SelectedParameterMessage) {
        pmController?.selectedParam = param
    }
    
    ///MARK: - PowerMate Delegate
    
    func didConnect() {
        DispatchQueue.main.async {
            self.powerMateLabel.stringValue = "PowerMate: Connected"
        }
        
    }
    
    func didDisconnect() {
        DispatchQueue.main.async {
            self.powerMateLabel.stringValue = "PowerMate: Not Connected"
        }
       
    }
}
