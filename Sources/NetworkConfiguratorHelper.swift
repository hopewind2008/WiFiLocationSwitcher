import Foundation
import Security

@objc(NetworkConfiguratorHelper)
class NetworkConfiguratorHelper: NSObject {
    static let shared = NetworkConfiguratorHelper()
    
    private var authRef: AuthorizationRef?
    
    override init() {
        super.init()
        var auth: AuthorizationRef?
        let status = AuthorizationCreate(nil, nil, [], &auth)
        if status == errAuthorizationSuccess {
            self.authRef = auth
        }
    }
    
    func executeNetworkCommand(_ command: String, arguments: [String]) throws -> Bool {
        guard let authRef = authRef else {
            throw NSError(domain: "NetworkConfiguratorError",
                         code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Authorization not available"])
        }
        
        var error: OSStatus = noErr
        var authItem = AuthorizationItem(name: kAuthorizationRightExecute, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let authFlags: AuthorizationFlags = [.interactionAllowed, .extendRights]
        
        error = AuthorizationCopyRights(authRef, &authRights, nil, authFlags, nil)
        guard error == errAuthorizationSuccess else {
            throw NSError(domain: "NetworkConfiguratorError",
                         code: Int(error),
                         userInfo: [NSLocalizedDescriptionKey: "Failed to copy rights"])
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        return process.terminationStatus == 0
    }
} 