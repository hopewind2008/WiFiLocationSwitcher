import XCTest
@testable import WiFiLocationSwitcher

class IntegrationTests: XCTestCase {
    var appDelegate: AppDelegate!
    var monitor: WiFiMonitor!
    var configurator: NetworkConfigurator!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        monitor = WiFiMonitor()
        configurator = NetworkConfigurator.shared
        
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
    }
    
    func testCompleteWorkflow() {
        // 测试完整工作流程
        let expectation = XCTestExpectation(description: "Complete workflow")
        
        // 模拟 WiFi 变化
        NotificationCenter.default.addObserver(forName: .locationChanged, object: nil, queue: nil) { notification in
            guard let location = notification.userInfo?["location"] as? String else {
                XCTFail("位置信息缺失")
                return
            }
            
            XCTAssertTrue(location == "公司" || location == "宿舍")
            XCTAssertEqual(self.appDelegate.locationMenuItem.title, "当前位置: \(location)")
            
            expectation.fulfill()
        }
        
        // 触发配置切换
        configurator.switchConfig(for: "hongzhi")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNetworkSettingsChange() {
        // 测试网络设置更改
        // 注意：这个测试需要管理员权限
        let expectation = XCTestExpectation(description: "Network settings change")
        
        // 执行网络设置更改
        configurator.switchConfig(for: "hongzhi")
        
        // 给系统一些时间应用设置
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 验证网络设置
            // 注意：这需要实际的网络命令执行权限
            let process = Process()
            process.launchPath = "/usr/sbin/networksetup"
            process.arguments = ["-getinfo", "Wi-Fi"]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)
                
                XCTAssertNotNil(output)
                XCTAssertTrue(output?.contains("192.168.3.112") ?? false)
                
                expectation.fulfill()
            } catch {
                XCTFail("无法执行网络设置验证: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
} 