//
//  MainMenuController.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/27/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Cocoa

class MainMenuController: NSMenu {
    
    @IBOutlet weak var statusDetailView: StatusDetail!
    
    var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        setupUi()
    }
    
    func setupUi() {
        setStatusIcon()
        statusBarItem.menu = self
        NetworkManager.shared.start()
        let i = item(withTitle: "Status")
        i?.view = statusDetailView
    }
    
    func setStatusIcon() {
        let icon = NSImage(named: "StatusIcon")
        icon?.isTemplate = true
        statusBarItem.button?.image = icon
    }
    
    @IBAction func quitTapped(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
    @IBAction func restartTapped(_ sender: Any) {
        NetworkManager.shared.restartService()
    }
}
