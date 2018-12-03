//
//  LightroomClinet.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/28/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol LightroomClientDelegate {
    
    /// Lightrom clients connection has changed
    func lrConnectionHasChanged(_ connected: Bool)
    
    /// Lightroom did revieve data
    func didRecieveDataFromLr(_ data: Data)
}

class LightroomClient: NSObject, GCDAsyncSocketDelegate {
    
    private var socket: GCDAsyncSocket?
    var delegate: LightroomClientDelegate?
    
    func start(port: UInt16) {
        
        if socket?.isConnected == true {
            socket?.disconnect()
        }
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main, socketQueue: DispatchQueue.main)
        do {
            try socket?.connect(toHost: "localhost", onPort: port, withTimeout: 5.0)
        } catch let error {
            print("Cannot connect to Lightroom with port: \(port): \(error)")
        }
    }
    
    func stop() {
        socket?.disconnect()
    }
    
    func restart(_ port: UInt16) {
        start(port: port)
    }
    
    func write(_ data: Data) {
        if let c = socket {
            c.write(data, withTimeout: Constants.defaultWriteTimeOut, tag: 0)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
        delegate?.lrConnectionHasChanged(true)
        print("Socket connected to Lightroom with port: \(port)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        delegate?.didRecieveDataFromLr(data)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        delegate?.lrConnectionHasChanged(false)
        print("Closed with error: \(err?.localizedDescription ?? "Empty error description")")
    }
}

