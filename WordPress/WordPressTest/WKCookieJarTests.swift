import XCTest
import WebKit
@testable import WordPress

class WKCookieJarTests: XCTestCase {
    var wkCookieStore: WKHTTPCookieStore!
    var cookieJar: CookieJar {
        return wkCookieStore
    }
    let wordPressComLoginURL = URL(string: "https://wordpress.com/wp-login.php")!

    override func setUp() {
        super.setUp()
        wkCookieStore = WKWebsiteDataStore.nonPersistent().httpCookieStore
        addCookies()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetCookies() {
        XCTExpectFailure(
            "WKHTTPCookieStore tests fail on Xcode 15+. The calling setCookie on the store does not seem to set the cookie...",
            options: .nonStrict()
        )

        let expectation = self.expectation(description: "getCookies completion called")
        cookieJar.getCookies(url: wordPressComLoginURL) { (cookies) in
            XCTAssertEqual(cookies.count, 1, "Should be one cookie for wordpress.com")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testHasCookieMatching() {
        XCTExpectFailure(
            "WKHTTPCookieStore tests fail on Xcode 15+. The calling setCookie on the store does not seem to set the cookie...",
            options: .nonStrict()
        )

        let expectation = self.expectation(description: "hasCookie completion called")
        cookieJar.hasWordPressComAuthCookie(username: "testuser", atomicSite: false) { (matches) in
            XCTAssertTrue(matches, "Cookies should exist for wordpress.com + testuser")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)

    }

    func testHasCookieNotMatching() {
        XCTExpectFailure(
            "WKHTTPCookieStore tests fail on Xcode 15+. The calling setCookie on the store does not seem to set the cookie...",
            options: .nonStrict()
        )

        let expectation = self.expectation(description: "hasCookie completion called")
        cookieJar.hasWordPressComAuthCookie(username: "anotheruser", atomicSite: false) { (matches) in
            XCTAssertFalse(matches, "Cookies should not exist for wordpress.com + anotheruser")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRemoveCookies() {
        XCTExpectFailure(
            "WKHTTPCookieStore tests fail on Xcode 15+. The calling setCookie on the store does not seem to set the cookie...",
            options: .nonStrict()
        )

        let expectation = self.expectation(description: "removeCookies completion called")
        cookieJar.removeWordPressComCookies { [wkCookieStore] in
            wkCookieStore!.getAllCookies { cookies in
                XCTAssertEqual(cookies.count, 1)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

private extension WKCookieJarTests {
    func addCookies() {
        wkCookieStore.setWordPressComCookie(username: "testuser")
        wkCookieStore.setWordPressCookie(username: "testuser", domain: "example.com")
    }
}
