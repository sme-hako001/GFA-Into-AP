//
//  GFATests.swift
//  GFATests
//
//  Created by Khachatur Hakobyan Sony on 3/9/23.
//

import XCTest
@testable import GFA

final class GFATests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_1_GFACoordinator() {
        XCTAssertNil(GFACoordinator.shared, "GFACoordinator.shared should be nil before initialized.")
    }

    func test_2_GFACoordinator() {
        _ = GFACoordinator(UINavigationController())

        XCTAssertNotNil(GFACoordinator.shared, "GFACoordinator.shared should not be nil.")
    }

    func test_3_Credentials() {
        _ = GFACoordinator(UINavigationController())

        XCTAssertNil(SMESettingsManager()!.credentials, "SMESettingsManager()!.credentials should be nil.")
    }

    func test_4_Credentials() {
        _ = GFACoordinator(UINavigationController())

        SMESettingsManager()!.credentials = Credentials()

        XCTAssertNotNil(SMESettingsManager()!.credentials, "SMESettingsManager()!.credentials should not be nil.")
    }

    func test_5_Credentials() {
        self.test_4_Credentials()

        GFACoordinator.shared.start(cleanCredentials: true)

        XCTAssertNil(SMESettingsManager()!.credentials, "SMESettingsManager()!.credentials should be nil.")
    }

    func test_6_Localizable() {
        XCTAssertEqual("alertConfirmDeleteDocumentTitle".localized, "The document will be deleted.")
        XCTAssertEqual("alertConfirmDeleteDocumentMessage".localized, "Are you sure you want to proceed?")
        XCTAssertEqual("alertLoginFailedTitle".localized, "Login Failed")
        XCTAssertEqual("alertDocuemntsListRequestFailed".localized, "Unable to load documents")
    }

    func test_7_Images() {
        XCTAssertNil(UIImage(named: "delete_icon", in: .none, compatibleWith: .none))

        XCTAssertNotNil(UIImage(named: "delete_icon", in: .gfa, compatibleWith: .none))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
