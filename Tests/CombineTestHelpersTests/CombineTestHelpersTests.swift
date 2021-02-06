import Combine
@testable import CombineTestHelpers
import XCTest

final class CombineTestHelpersTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    func testExample() {
        let e = XCTestExpectation(description: "")

        doesThisCompile()
        .sink(
            receiveCompletion: { c in
                guard case .finished = c else { return }
                e.fulfill()
            },
            receiveValue: {
                XCTAssertEqual($0, 42)
            }
            )
        .store(in: &cancellables)

        wait(for: [e], timeout: 0.1)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
