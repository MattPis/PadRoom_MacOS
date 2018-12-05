//
//  NetworkManager.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/27/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

/// Network Manager Delegate Protocol
protocol NetworkManagerDelegate {
    
    /// client is either accepted or disconneted
    /// - parameter count: number of currently connected clients
    func clientsCountHasChanged(_ count: Int)
    
    /// Lightrom clients connection has changed
    /// - parameter connected: connection flag
    func lrConnectionHasChanged(_ connected: Bool)
    
    /// Network Manager did revieve adjustment parameter for PowerMate
    /// - parameter param: selected param
    func DidRecieveSelectedParameter(_ param: SelectedParameterMessage)
}

/// Manages network and Lightroom connections.
class NetworkManager: SocketServerDelegate, LightroomClientDelegate  {

    static let shared = NetworkManager()
    private let server = SocketServer()
    private let lrSend = LightroomClient()
    private let lrRecieve = LightroomClient()
    var delegate: NetworkManagerDelegate?
    
    func start() {
        server.start()
        server.delegate = self
        
        lrSend.start(port: Constants.LRSendPort)
        lrSend.delegate = self
        
        lrRecieve.start(port: Constants.LRReceivePort)
        lrRecieve.delegate = self
    }
    
    func stopService() {
        server.stop()
        lrSend.stop()
        lrRecieve.stop()
    }
    
    func restartService() {
        server.restart()
        lrSend.restart(Constants.LRSendPort)
        lrRecieve.restart(Constants.LRReceivePort)
    }
    
    ///MARK: - Server Delegate
    func clientsCountHasChanged(_ count: Int) {
        delegate?.clientsCountHasChanged(count)
    }
    
    func serverDidRead(data: Data) {
        print("Did recieve data from LR: \(String(describing: String(data: data, encoding: .utf8)))")
        guard let d = clientMessageRecieved(data: data) else { return }
        lrSend.write(d)
    }
    
    ///MARK: - LR Delegate
    func lrConnectionHasChanged(_ connected: Bool) {
        delegate?.lrConnectionHasChanged(connected)
    }
    
    func didRecieveDataFromLr(_ data: Data) {
        print("Did recieve data from LR: \(String(describing: String(data: data, encoding: .utf8)))")
        server.writeToClients(data)
    }
    
    func writeToLr(_ data: Data) {
        lrSend.write(data)
    }
    
    /// Returns IP address of WiFi interface as a String, or nil
    public static func ipAddress() -> String? {
        var address : String?
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

extension NetworkManager  {
    
    /// Intercept data from client app and parse for selected param.
    /// Calls delegate if selected param present.
    /// - parameter data: data form client app
    /// - returns: data if no selectedTool present, nil if true
    func clientMessageRecieved(data: Data) -> Data? {
        guard let selectedParam = try? JSONDecoder().decode(SelectedParameterMessage.self, from: data) else {
            return data
        }
        delegate?.DidRecieveSelectedParameter(selectedParam)
        return nil
    }
}




