//
//  PacketTunnelProvider.swift
//  DiOSAPP_Extension
//
//  Created by Alex M on 7/24/19.
//  Copyright © 2019 Alex M. All rights reserved.
//

import NetworkExtension
import TunnelKit
class PacketTunnelProvider: OpenVPNTunnelProvider {
}

//class PacketTunnelProvider: NEPacketTunnelProvider {
//
//    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
//        // Add code here to start the process of connecting the tunnel.
//    }
//
//    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
//        // Add code here to start the process of stopping the tunnel.
//        completionHandler()
//    }
//
//    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        // Add code here to handle the message.
//        if let handler = completionHandler {
//            handler(messageData)
//        }
//    }
//
//    override func sleep(completionHandler: @escaping () -> Void) {
//        // Add code here to get ready to sleep.
//        completionHandler()
//    }
//
//    override func wake() {
//        // Add code here to wake up.
//    }
//}
