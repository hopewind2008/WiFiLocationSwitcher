//
//  AppDelegate.swift
//  WiFiLocationSwitcher
//
//  @description: 应用程序的主入口,负责初始化状态栏菜单和WiFi监控
//  @author: Your Name
//  @date: 2024-01-xx
//

import Cocoa
import ServiceManagement
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    /// 状态栏图标项
    var statusItem: NSStatusItem!
    
    /// WiFi监控器实例
    let wifiMonitor = WiFiMonitor()
    
    /// 显示当前位置的菜单项
    var locationMenuItem: NSMenuItem!
    
    /// 状态显示菜单项
    var statusMenuItem: NSMenuItem!
    
    /// 设置窗口控制器
    private var settingsWindowController: NSWindowController?
    
    /// 开机启动的 Bundle Identifier
    private let launcherBundleId = "com.hopewind.WiFiLocationSwitcher.LaunchHelper"
    
    /// 应用程序启动时的初始化
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("应用程序启动...")
        
        // 请求通知权限
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("通知权限已授予")
            } else if let error = error {
                print("通知权限请求失败: \(error)")
            }
        }
        
        // 设置状态栏图标
        setupStatusItem()
        print("状态栏图标已设置")
        
        // 初始化菜单
        setupMenu()
        print("菜单已初始化")
        
        // 启动WiFi监控
        wifiMonitor.startMonitoring()
        print("WiFi监控已启动")
        
        // 注册位置变化通知监听
        setupNotifications()
        print("通知监听已注册")
        
        // 立即检查当前WiFi状态
        if let ssid = wifiMonitor.getCurrentWiFiSSID() {
            print("当前WiFi: \(ssid)")
            NetworkConfigurator.shared.switchConfig(for: ssid)
        }
    }
    
    /// 设置状态栏菜单
    func setupMenu() {
        let menu = NSMenu()
        
        // 状态显示
        statusMenuItem = NSMenuItem(title: "状态: 就绪", action: nil, keyEquivalent: "")
        menu.addItem(statusMenuItem)
        
        // 位置显示
        locationMenuItem = NSMenuItem(title: "当前位置: 未知", action: nil, keyEquivalent: "")
        menu.addItem(locationMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 重试选项
        let retryItem = NSMenuItem(title: "重试上次配置", action: #selector(retryLastConfig), keyEquivalent: "r")
        retryItem.target = self
        menu.addItem(retryItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // ���机启动选项
        let launchAtLoginItem = NSMenuItem(title: "开机启动", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchAtLoginItem)
        
        // 添加设置菜单项
        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    /// 更新位置显示
    /// - Parameter notification: 包含新位置信息的通知对象
    @objc func updateLocation(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? String {
            locationMenuItem.title = "当前位置: \(location)"
        }
    }
    
    /// 更新状态显示
    /// - Parameter notification: 包含新状态信息的通知对象
    @objc func updateStatus(_ notification: Notification) {
        if let status = notification.userInfo?["status"] as? String {
            statusMenuItem.title = "状���: \(status)"
            
            // 更新状态栏图标
            switch status {
            case "配置中...":
                statusItem.button?.title = "⏳"
            case "配置成功":
                statusItem.button?.title = "📡"
                showNotification("网络配置已更新", "新的网络配置已成功应用")
            case "配置失败":
                statusItem.button?.title = "⚠️"
                showNotification("网络配置失败", "请点击状态栏图标查看详情")
            default:
                statusItem.button?.title = "📡"
            }
        }
    }
    
    /// 重试上次配置
    @objc func retryLastConfig() {
        NetworkConfigurator.shared.retryLastConfig()
    }
    
    /// 设置状态栏图标
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "📡"
    }
    
    /// 注册通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocation(_:)),
            name: .locationChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatus(_:)),
            name: .configurationStatusChanged,
            object: nil
        )
    }
    
    /// 显示通知
    private func showNotification(_ title: String, _ message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @objc func openSettings() {
        // 如果窗口已存在，就显示并前置
        if let windowController = settingsWindowController {
            windowController.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // 使用 xib 文件创建设置视图控制器
        let settingsVC = SettingsViewController(nibName: "Settings", bundle: Bundle.main)
        
        // 创建新窗口
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = settingsVC
        window.title = "设置"
        
        // 创建窗口控制器
        let windowController = NSWindowController(window: window)
        windowController.shouldCascadeWindows = true
        settingsWindowController = windowController
        
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// 检查是否启用开机启动
    private func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            // 旧版本 macOS 的检查方法
            let jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]] ?? []
            return jobs.contains { ($0["Label"] as? String) == launcherBundleId }
        }
    }
    
    /// 切换开机启动状态
    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                    sender.state = .off
                } else {
                    try SMAppService.mainApp.register()
                    sender.state = .on
                }
            } catch {
                print("切换开机启动状态失败: \(error)")
                showNotification("开机启动设置失败", error.localizedDescription)
            }
        } else {
            // 旧版本 macOS 的设置方法
            let success = SMLoginItemSetEnabled(launcherBundleId as CFString, !isLaunchAtLoginEnabled())
            if success {
                sender.state = sender.state == .on ? .off : .on
            } else {
                print("切换开机启动状态失败")
                showNotification("开机启动设置失败", "无法修改系统设置")
            }
        }
    }
    
    // 实现通知代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window === settingsWindowController?.window else { return }
        settingsWindowController = nil
    }
}

