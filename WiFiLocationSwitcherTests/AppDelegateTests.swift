import XCTest
@testable import WiFiLocationSwitcher

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }
    
    func testStatusItemSetup() {
        // 测试状态栏图标设置
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        
        XCTAssertNotNil(appDelegate.statusItem.button)
        XCTAssertEqual(appDelegate.statusItem.button?.title, "📡")
    }
    
    func testMenuSetup() {
        // 测试菜单设置
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        
        XCTAssertNotNil(appDelegate.statusItem.menu)
        XCTAssertEqual(appDelegate.locationMenuItem.title, "当前位置: 未知")
    }
    
    func testLocationUpdate() {
        // 测试位置更新
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        
        appDelegate.updateLocation(Notification(
            name: .locationChanged,
            object: nil,
            userInfo: ["location": "公司"]
        ))
        
        XCTAssertEqual(appDelegate.locationMenuItem.title, "当前位置: 公司")
    }
} 