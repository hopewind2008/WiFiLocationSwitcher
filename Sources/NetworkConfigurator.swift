//
//  NetworkConfigurator.swift
//  WiFiLocationSwitcher
//
//  @description: 网络配置管理器,负责存储和切换不同位置的网络设置
//  @author: Your Name
//  @date: 2024-01-xx
//

import Foundation
import Security

class NetworkConfigurator {
    /// 单例实例
    static let shared = NetworkConfigurator()
    
    private var authRef: AuthorizationRef?
    
    /// 最后一次配置
    private var lastConfig: NetworkConfig?
    
    /// 最大重试次数
    private let maxRetries = 3
    
    /// 重试当前配置
    private var currentRetries = 0
    
    /// 配置存储路径
    private let configPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("WiFiLocationSwitcher")
        .appendingPathComponent("configs.json")
    
    /// 网络配置字典
    private(set) var configs: [String: NetworkConfig] = [:]
    
    init() {
        createConfigDirectory()
        loadConfigs()
        
        if configs.isEmpty {
            // 添加默认配置
            configs = [
                "hongzhi": NetworkConfig(
                    location: "公司",
                    ip: "192.168.3.112",
                    subnet: "255.255.255.0",
                    gateway: "192.168.3.1",
                    dns: ["202.96.104.15"]
                ),
                "TP-LINK_5G_m": NetworkConfig(
                    location: "宿舍", 
                    ip: "192.168.31.102",
                    subnet: "255.255.255.0",
                    gateway: "192.168.31.7",
                    dns: ["192.168.31.7"]
                )
            ]
            saveConfigs()
        }
        
        var auth: AuthorizationRef?
        var rights = AuthorizationRights(count: 0, items: nil)
        let flags: AuthorizationFlags = [.extendRights, .interactionAllowed, .preAuthorize]
        
        let status = AuthorizationCreate(&rights, nil, flags, &auth)
        if status == errAuthorizationSuccess {
            self.authRef = auth
            print("权限初始化成功")
        } else {
            print("权限初始化失败: \(status)")
        }
    }
    
    deinit {
        if let authRef = authRef {
            AuthorizationFree(authRef, [])
        }
    }
    
    /// 网络配置结构体
    struct NetworkConfig {
        /// 位置名称(如"公司"、"宿舍")
        let location: String
        /// IP地址
        let ip: String
        /// 子网掩码
        let subnet: String
        /// 网关地址
        let gateway: String
        /// DNS服务器列表
        let dns: [String]
        
        // 添加默认值
        init(location: String, ip: String, subnet: String, gateway: String, dns: [String] = ["202.96.104.15"]) {
            self.location = location
            self.ip = ip
            self.subnet = subnet
            self.gateway = gateway
            self.dns = dns
        }
    }
    
    /// 创建配置目录
    private func createConfigDirectory() {
        guard let configPath = configPath else { return }
        try? FileManager.default.createDirectory(
            at: configPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    /// 加载配置
    private func loadConfigs() {
        guard let configPath = configPath,
              let data = try? Data(contentsOf: configPath),
              let configs = try? JSONDecoder().decode([String: NetworkConfig].self, from: data)
        else { return }
        
        self.configs = configs
    }
    
    /// 保存配置
    private func saveConfigs() {
        guard let configPath = configPath,
              let data = try? JSONEncoder().encode(configs)
        else { return }
        
        try? data.write(to: configPath)
    }
    
    /// 添加配置
    func addConfig(_ config: NetworkConfig, for ssid: String) {
        configs[ssid] = config
        saveConfigs()
    }
    
    /// 删除配置
    func removeConfig(for ssid: String) {
        configs.removeValue(forKey: ssid)
        saveConfigs()
    }
    
    /// 更新配置
    func updateConfig(_ config: NetworkConfig, for ssid: String) {
        configs[ssid] = config
        saveConfigs()
    }
    
    /// 发送状态更新通知
    private func updateStatus(_ status: String) {
        NotificationCenter.default.post(
            name: .configurationStatusChanged,
            object: nil,
            userInfo: ["status": status]
        )
    }
    
    /// 切换网络配置
    /// - Parameter ssid: WiFi的SSID
    func switchConfig(for ssid: String) {
        guard let config = configs[ssid] else {
            updateStatus("未找到配置")
            return
        }
        
        lastConfig = config
        currentRetries = 0
        
        NotificationCenter.default.post(
            name: .locationChanged,
            object: nil,
            userInfo: ["location": config.location]
        )
        
        applyNetworkConfig(config)
    }
    
    /// 重试上次配置
    func retryLastConfig() {
        guard let config = lastConfig else {
            updateStatus("没有可重试的配置")
            return
        }
        
        currentRetries = 0
        applyNetworkConfig(config)
    }
    
    /// 应用网络配置
    /// - Parameter config: 要应用的网络配置
    private func applyNetworkConfig(_ config: NetworkConfig) {
        updateStatus("配置中...")
        
        // 构建完整的配置命令
        let commands = [
            "/usr/sbin/networksetup -setdnsservers Wi-Fi \(config.dns.joined(separator: " "))",
            "/usr/sbin/networksetup -setmanual Wi-Fi \(config.ip) \(config.subnet) \(config.gateway)"
        ]
        
        // 使用 AppleScript 执行多个命令
        let script = """
        tell application "System Events"
            activate
            do shell script "\(commands.joined(separator: " && "))" with administrator privileges
        end tell
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        print("执行命令: \(commands.joined(separator: " && "))")
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
                print("命令输出: \(output)")
            }
            
            if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
                print("错误输出: \(error)")
            }
            
            let success = process.terminationStatus == 0
            if success {
                updateStatus("配置成功")
                // 验证配置
                verifyNetworkConfig(config) { verified in
                    if verified {
                        self.updateStatus("配置已验证")
                    } else {
                        self.handleConfigurationFailure(config, error: "配置验证失败")
                    }
                }
            } else {
                handleConfigurationFailure(config, error: "配置应用失败")
            }
        } catch {
            handleConfigurationFailure(config, error: error.localizedDescription)
        }
    }
    
    /// 处理配置失败
    private func handleConfigurationFailure(_ config: NetworkConfig, error: String) {
        print("配置失败: \(error)")
        
        if currentRetries < maxRetries {
            currentRetries += 1
            print("尝试重试 (\(currentRetries)/\(maxRetries))")
            updateStatus("重试中... (\(currentRetries)/\(maxRetries))")
            
            // 延迟 1 秒后重试
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.applyNetworkConfig(config)
            }
        } else {
            updateStatus("配置失败")
            print("达到最大重试次数")
        }
    }
    
    /// 验证网络配置
    private func verifyNetworkConfig(_ config: NetworkConfig, completion: @escaping (Bool) -> Void) {
        let getInfoArgs = ["-getinfo", "Wi-Fi"]
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        process.arguments = getInfoArgs
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("当前网络配置:\n\(output)")
                
                let success = output.contains(config.ip) &&
                             output.contains(config.subnet) &&
                             output.contains(config.gateway)
                
                if success {
                    print("网络配置验证成功")
                } else {
                    print("网络配置验证失败")
                }
                completion(success)
            } else {
                print("无法读取网络配置")
                completion(false)
            }
        } catch {
            print("验证网络配置失败: \(error)")
            completion(false)
        }
    }
}

/// 通知名称扩展
extension Notification.Name {
    /// 位置变化通知
    static let locationChanged = Notification.Name("locationChanged")
    /// 配置状态变化通知
    static let configurationStatusChanged = Notification.Name("configurationStatusChanged")
} 

// 使 NetworkConfig 可编码
extension NetworkConfigurator.NetworkConfig: Codable {} 
