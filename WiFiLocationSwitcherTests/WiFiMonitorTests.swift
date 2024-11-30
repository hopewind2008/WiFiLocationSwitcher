import XCTest
import CoreWLAN
@testable import WiFiLocationSwitcher

class WiFiMonitorTests: XCTestCase {
    var monitor: WiFiMonitor!
    
    override func setUp() {
        super.setUp()
        monitor = WiFiMonitor()
    }
    
    func testWiFiClientInitialization() {
        XCTAssertNotNil(monitor.client)
    }
    
    func testWiFiInterface() {
        // 测试是否能获取到 WiFi 接口
        XCTAssertNotNil(monitor.client.interface())
    }
    
    func testSSIDDetection() {
        // 测试 SSID 检测
        guard let interface = monitor.client.interface() else {
            XCTFail("无法获取 WiFi 接口")
            return
        }
        
        // 获取当前 SSID
        let ssid = interface.ssid()
        XCTAssertNotNil(ssid, "无法获取当前 SSID")
    }
} 