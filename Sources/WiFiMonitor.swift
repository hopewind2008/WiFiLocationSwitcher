//
//  WiFiMonitor.swift
//  WiFiLocationSwitcher
//
//  @description: WiFi监控器,负责监控WiFi连接状态的变化
//  @author: Your Name
//  @date: 2024-01-xx
//

import Foundation
import CoreWLAN
import SystemConfiguration

class WiFiMonitor: NSObject {
    private let wifiClient = CWWiFiClient.shared()
    
    func startMonitoring() {
        do {
            // 设置代理来监听 WiFi 事件
            try wifiClient.startMonitoringEvent(with: .ssidDidChange)
            print("WiFi 监控已启动")
        } catch {
            print("启动 WiFi 监控失败: \(error)")
        }
    }
    
    public func getCurrentWiFiSSID() -> String? {
        guard let interface = wifiClient.interface() else {
            print("无法获取 WiFi 接口")
            return nil
        }
        do {
            return try interface.ssid()
        } catch {
            print("获取 SSID 失败: \(error)")
            return nil
        }
    }
}

// MARK: - CWEventDelegate
extension WiFiMonitor: CWEventDelegate {
    func clientDidFinishEvent(withType type: CWEventType, error: Error?) {
        switch type {
        case .ssidDidChange:
            if let ssid = getCurrentWiFiSSID() {
                print("WiFi SSID 已变更为: \(ssid)")
                NetworkConfigurator.shared.switchConfig(for: ssid)
            }
        case .powerDidChange:
            print("WiFi 电源状态已变更")
            break
        default:
            break
        }
    }
} 