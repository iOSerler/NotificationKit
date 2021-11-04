import XCTest
@testable import NotificationKit

final class NotificationKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let config = PermissionConfiguration()
        let manager = PermissionManager(notificationConfig: config, analytics: nil)
        let hostVC = UIViewController()
        manager.hostController = hostVC
        XCTAssertNotNil(manager.hostController)
    }
}
