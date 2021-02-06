import Combine
import CombineTestHelpers
import XCTest

class IntegrationTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testIntegration() {
        XCTAssertTrue(true)

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
}
