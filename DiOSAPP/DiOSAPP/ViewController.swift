//
//  ViewController.swift
//  DiOSAPP
//
//  Created by Alex M on 7/24/19.
//  Copyright © 2019 Alex M. All rights reserved.
//

import UIKit
import NetworkExtension
import TunnelKit
import WebKit


private let ca = OpenVPN.CryptoContainer(pem: """
-----BEGIN CERTIFICATE-----
MIIDyzCCAzSgAwIBAgIJAKRtpjsIvek1MA0GCSqGSIb3DQEBBQUAMIGgMQswCQYD
VQQGEwJDSDEPMA0GA1UECBMGWnVyaWNoMQ8wDQYDVQQHEwZadXJpY2gxFDASBgNV
BAoTC3ZwbmJvb2suY29tMQswCQYDVQQLEwJJVDEUMBIGA1UEAxMLdnBuYm9vay5j
b20xFDASBgNVBCkTC3ZwbmJvb2suY29tMSAwHgYJKoZIhvcNAQkBFhFhZG1pbkB2
cG5ib29rLmNvbTAeFw0xMzA0MjQwNDA3NDhaFw0yMzA0MjIwNDA3NDhaMIGgMQsw
CQYDVQQGEwJDSDEPMA0GA1UECBMGWnVyaWNoMQ8wDQYDVQQHEwZadXJpY2gxFDAS
BgNVBAoTC3ZwbmJvb2suY29tMQswCQYDVQQLEwJJVDEUMBIGA1UEAxMLdnBuYm9v
ay5jb20xFDASBgNVBCkTC3ZwbmJvb2suY29tMSAwHgYJKoZIhvcNAQkBFhFhZG1p
bkB2cG5ib29rLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAyNwZEYs6
WN+j1zXYLEwiQMShc1mHmY9f9cx18hF/rENG+TBgaS5RVx9zU+7a9X1P3r2OyLXi
WzqvEMmZIEhij8MtCxbZGEEUHktkbZqLAryIo8ubUigqke25+QyVLDIBuqIXjpw3
hJQMXIgMic1u7TGsvgEUahU/5qbLIGPNDlUCAwEAAaOCAQkwggEFMB0GA1UdDgQW
BBRZ4KGhnll1W+K/KJVFl/C2+KM+JjCB1QYDVR0jBIHNMIHKgBRZ4KGhnll1W+K/
KJVFl/C2+KM+JqGBpqSBozCBoDELMAkGA1UEBhMCQ0gxDzANBgNVBAgTBlp1cmlj
aDEPMA0GA1UEBxMGWnVyaWNoMRQwEgYDVQQKEwt2cG5ib29rLmNvbTELMAkGA1UE
CxMCSVQxFDASBgNVBAMTC3ZwbmJvb2suY29tMRQwEgYDVQQpEwt2cG5ib29rLmNv
bTEgMB4GCSqGSIb3DQEJARYRYWRtaW5AdnBuYm9vay5jb22CCQCkbaY7CL3pNTAM
BgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4GBAKaoCEWk2pitKjbhChjl1rLj
6FwAZ74bcX/YwXM4X4st6k2+Fgve3xzwUWTXinBIyz/WDapQmX8DHk1N3Y5FuRkv
wOgathAN44PrxLAI8kkxkngxby1xrG7LtMmpATxY7fYLOQ9yHge7RRZKDieJcX3j
+ogTneOl2w6P0xP6lyI6
-----END CERTIFICATE-----
""")
extension ViewController {
    private static let appGroup = "group.com.DiOSAPP.openVPN"
    
    private static let tunnelIdentifier = "com.DiOSAPP.openVPN"
    
    private func makeProtocol() -> NETunnelProviderProtocol {
        let server = "pl226"
        let domain = "vpnbook.com"
        
        let hostname = ((domain == "") ? server : [server, domain].joined(separator: "."))
        let port = UInt16("25000")!
        let credentials = OpenVPN.Credentials("vpnbook", "vb2PPb6")
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = ca
        sessionBuilder.cipher = .aes128cbc
        sessionBuilder.digest = .sha1
        sessionBuilder.compressionFraming = .compLZO
        sessionBuilder.renegotiatesAfter = nil
        sessionBuilder.hostname = hostname
       // let socketType: SocketType = switchTCP.isOn ? .tcp : .udp
        sessionBuilder.endpointProtocols = [EndpointProtocol(.udp, port)]
        sessionBuilder.usesPIAPatches = true
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.mtu = 1350
        builder.shouldDebug = true
        builder.masksPrivateData = false
        
        let configuration = builder.build()
        return try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: ViewController.tunnelIdentifier,
            appGroup: ViewController.appGroup,
            credentials: credentials
        )
    }
}


class ViewController: UIViewController, WKUIDelegate{

    var webView: WKWebView!
    var currentManager: NETunnelProviderManager?
    var status = NEVPNStatus.invalid
    
    //@IBOutlet weak var webview: WKWebView!
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     //   webview.navigationDelegate = self
       
        loadMyCompanyWebPage()
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        reloadCurrentManager(nil)
        
        //
        
        testFetchRef()
        
        connection()
        loadMyCompanyWebPage()
        // Do any additional setup after loading the view.
    }
    
    func loadMyCompanyWebPage(){
        
        let myURL = URL(string:"https://msn.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func connection() {
        let block = {
            switch (self.status) {
            case .invalid, .disconnected:
                self.connect()
                
            case .connected, .connecting:
                self.disconnect()
                
            default:
                break
            }
        }
        
        if (status == .invalid) {
            reloadCurrentManager({ (error) in
                block()
            })
        }
        else {
            block()
        }
    }
    
    
    func connect() {
        configureVPN({ (manager) in
            return self.makeProtocol()
        }, completionHandler: { (error) in
            if let error = error {
                print("configure error: \(error)")
                return
            }
            let session = self.currentManager?.connection as! NETunnelProviderSession
            do {
                try session.startTunnel()
            } catch let e {
                print("error starting tunnel: \(e)")
            }
        })
    }
    
    func disconnect() {
        configureVPN({ (manager) in
            return nil
        }, completionHandler: { (error) in
            self.currentManager?.connection.stopVPNTunnel()
        })
    }
    
   func displayLog() {
        guard let vpn = currentManager?.connection as? NETunnelProviderSession else {
            return
        }
        try? vpn.sendProviderMessage(OpenVPNTunnelProvider.Message.requestLog.data) { (data) in
            guard let data = data, let log = String(data: data, encoding: .utf8) else {
                return
            }
            //self.textLog.text = log
        }
    }
    
    func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
        reloadCurrentManager { (error) in
            if let error = error {
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }
            
            let manager = self.currentManager!
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true
            
            manager.saveToPreferences { (error) in
                if let error = error {
                    print("error saving preferences: \(error)")
                    completionHandler(error)
                    return
                }
                print("saved preferences")
                self.reloadCurrentManager(completionHandler)
            }
        }
    }

    func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)?) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            var manager: NETunnelProviderManager?
            
            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if (p.providerBundleIdentifier == ViewController.tunnelIdentifier) {
                        manager = m
                        break
                    }
                }
            }
            
            if (manager == nil) {
                manager = NETunnelProviderManager()
            }
            
            self.currentManager = manager
            self.status = manager!.connection.status
            self.updateButton()
            completionHandler?(nil)
        }
    }
    
    @objc private func VPNStatusDidChange(notification: NSNotification) {
        guard let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        updateButton()
    }
    
    func updateButton() {
        switch status {
        case .connected, .connecting:
              print("Connected!!!")
        // TODO: Goto webview
            loadMyCompanyWebPage()
        case .disconnected:
            print("disConnected!!!")

        case .disconnecting:
            print("disConnected!!!")

        default:
            break
        }
    }
    
    private func testFetchRef() {
        //        let keychain = Keychain(group: ViewController.APP_GROUP)
        //        let username = "foo"
        //        let password = "bar"
        //
        //        guard let _ = try? keychain.set(password: password, for: username) else {
        //            print("Couldn't set password")
        //            return
        //        }
        //        guard let passwordReference = try? keychain.passwordReference(for: username) else {
        //            print("Couldn't get password reference")
        //            return
        //        }
        //        guard let fetchedPassword = try? Keychain.password(for: username, reference: passwordReference) else {
        //            print("Couldn't fetch password")
        //            return
        //        }
        //
        //        print("\(username) -> \(password)")
        //        print("\(username) -> \(fetchedPassword)")
    }
}

