import XCTest
@testable import WiFiLocationSwitcher

class NetworkConfiguratorTests: XCTestCase {
    var configurator: NetworkConfigurator!
    
    override func setUp() {
        super.setUp()
        configurator = NetworkConfigurator.shared
    }
    
    func testConfigExists() {
        // 测试配置是否存在
        XCTAssertNotNil(configurator.configs["hongzhi"])
        XCTAssertNotNil(configurator.configs["TP-LINK_5G_m"])
    }
    
    func testConfigValues() {
        // 测试公司网络配置
        let companyConfig = configurator.configs["hongzhi"]
        XCTAssertEqual(companyConfig?.location, "公司")
        XCTAssertEqual(companyConfig?.ip, "192.168.3.112")
        XCTAssertEqual(companyConfig?.subnet, "255.255.255.0")
        XCTAssertEqual(companyConfig?.gateway, "192.168.3.1")
        XCTAssertEqual(companyConfig?.dns, ["202.96.104.15"])
        
        // 测试宿舍网络配置
        let homeConfig = configurator.configs["TP-LINK_5G_m"]
        XCTAssertEqual(homeConfig?.location, "宿舍")
        XCTAssertEqual(homeConfig?.ip, "192.168.31.102")
        XCTAssertEqual(homeConfig?.subnet, "255.255.255.0")
        XCTAssertEqual(homeConfig?.gateway, "192.168.31.7")
        XCTAssertEqual(homeConfig?.dns, ["192.168.31.7"])
    }
    
    func testLocationChangeNotification() {
        // 测试位置变化通知
        let expectation = XCTestExpectation(description: "Location change notification")
        
        NotificationCenter.default.addObserver(forName: .locationChanged, object: nil, queue: nil) { notification in
            XCTAssertEqual(notification.userInfo?["location"] as? String, "公司")
            expectation.fulfill()
        }
        
        configurator.switchConfig(for: "hongzhi")
        
        wait(for: [expectation], timeout: 1.0)
    }
} 