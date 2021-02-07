import Combine
import XCTest

public extension XCTestCase {

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishesOnly value: Output,
        timeout: Double = 1.0,
        description: String = "Publisher publishes exactly one expected value",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [.success(value)],
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishes expectedValues: [Result<Output, Failure>],
        timeout: Double = 1.0,
        description: String = "Publisher publishes expected values",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        let expectation = XCTestExpectation(description: description)
        var cancellables = Set<AnyCancellable>()
        var values: [Result<Output, Failure>] = []

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error): values.append(.failure(error))
                case .finished: break
                }
                expectation.fulfill()
            },
            receiveValue: {
                values.append(.success($0))
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(expectedValues, values, file: file, line: line)
    }
}
