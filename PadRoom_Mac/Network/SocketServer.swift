//
//  NetworkManager.swift
//  PadRoom_Mac
//
//  Created by Matt on 11/23/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket


/// SocketServer is using standatd Delegate pattern
protocol SocketServerDelegate {
    
    /// Called when client is either accepted or disconneted
    /// parameter: count - number of currently connected clients
    func clientsCountHasChanged(_ count: Int)
    
    /// Called when data has been read from a client
    /// parameter: data - data recieved from client
    func serverDidRead(data: Data)
}

/// Creates a socket server on network, listens, accepts and communicate with clients
///
class SocketServer: NSObject, GCDAsyncSocketDelegate {
    private var socket: GCDAsyncSocket?
    private var clients: [GCDAsyncSocket] = []
    var delegate: SocketServerDelegate?
    
    /// Starts service on default port
    ///
    func start() {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main, socketQueue: DispatchQueue.main)
        do {
            try socket?.accept(onPort: Constants.defaultPort)
        }
        catch {
            print("Error accpeting on socket")
        }

    }
    
    func stop() {
        let _ = clients.map { c in
            c.disconnect()
        }
        socket?.disconnect()
        socket = nil
        delegate?.clientsCountHasChanged(clients.count)
    }
    
    
    /// Stops and starts service on default port
    ///
    func restart() {
        stop()
        start()
    }
    
    func writeToClients(_ data: Data) {
        let _ = clients.map{ c in
            c.write(data, withTimeout: Constants.defaultWriteTimeOut, tag: 0)
        }
    }
    
    /// MARK: -- GCDAsyncSocketDelegate Methods
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        clients.append(newSocket)
        newSocket.readData(withTimeout: Constants.defaultReadTimeOut, tag: 0)
        delegate?.clientsCountHasChanged(clients.count)

        if let h =  newSocket.connectedHost {
            print("Client connected: \(h):\(newSocket.connectedPort)")
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        print("Socket read has timed out")
        return Constants.defaultReadTimeOut
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let i = clients.index(of: sock) {
            clients.remove(at: i)
        }
        delegate?.clientsCountHasChanged(clients.count)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: Constants.defaultReadTimeOut, tag: 0)
        delegate?.serverDidRead(data: data)
    }
    
}

