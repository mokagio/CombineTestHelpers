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
            eventuallyPublishes: [value],
            then: .none,
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyFinishesPublishingOnly value: Output,
        timeout: Double = 1.0,
        description: String = "Publisher publishes exactly one expected value then finishes",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [value],
            then: .finished,
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishesOnly value: Output,
        thenFailsWith error: Failure,
        timeout: Double = 1.0,
        description: String = "Publisher publishes exactly one expected value then fails",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [value],
            then: .failure(error),
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishes values: [Output],
        then completion: Subscribers.Completion<Failure>?,
        timeout: Double = 1.0,
        description: String = "Publisher publishes expected values",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        let expectation = XCTestExpectation(description: description)
        var cancellables = Set<AnyCancellable>()
        var publication = Publication<Output, Failure>()

        publisher.sink(
            receiveCompletion: { completion in
                publication = publication.updated(with: completion)
                expectation.fulfill()
            },
            receiveValue: {
                publication = publication.updated(with: $0)
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(publication.values, values)
        if let completion = completion {
            XCTAssertEqual(publication.completion, completion)
        }
    }
}

private struct Publication<Output, Failure>: Equatable where Output: Equatable, Failure: Equatable & Error {
    let values: [Output]
    let completion: Subscribers.Completion<Failure>?

    init(values: [Output] = [], completion: Subscribers.Completion<Failure>? = .none) {
        self.values = values
        self.completion = completion
    }

    func updated(with value: Output) -> Publication<Output, Failure> {
        Publication(values: values + [value], completion: completion)
    }

    // TODO: Throw custom error if already completed
    func updated(with completion: Subscribers.Completion<Failure>) -> Publication<Output, Failure> {
        Publication(values: values, completion: completion)
    }
}
