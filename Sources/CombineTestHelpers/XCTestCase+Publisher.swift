import Combine
import XCTest

public extension XCTestCase {

    func assert<Output, Failure>(
        publisherPublishesNoValue publisher: AnyPublisher<Output, Failure>,
        timeout: Double = 1.0,
        description: String = "Publisher publishes no value",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [],
            then: .none,
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        publishesNoValueThenFailsWith error: Failure,
        timeout: Double = 1.0,
        description: String = "Publisher publishes no value then fails",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [],
            then: .failure(error),
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        publisherPublishesNoValueThenFinishes publisher: AnyPublisher<Output, Failure>,
        timeout: Double = 1.0,
        description: String = "Publisher publishes no value then finishes",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: [],
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
        timeout: Double = 1.0,
        description: String = "Publisher publishes exactly one value",
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
        description: String = "Publisher publishes exactly one value then finishes",
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
        description: String = "Publisher publishes exactly one value then fails",
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
        eventuallyPublishesAtLeast value: Output,
        thenFailsWith error: Failure,
        timeout: Double = 1.0,
        description: String = "Publisher publishes at least one value then fails",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { publishedValues, file, line in
                XCTAssertEqual(publishedValues.first, value, file: file, line: line)
            },
            thenCompletesSatisfying: { publishedCompletion, file, line in
                XCTAssertEqual(publishedCompletion, .failure(error), file: file, line: line)
            },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyFinishesPublishingAtLeast value: Output,
        timeout: Double = 1.0,
        description: String = "Publisher publishes at least one value then finishes",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { publishedValues, file, line in
                XCTAssertEqual(publishedValues.first, value, file: file, line: line)
            },
            thenCompletesSatisfying: { publishedCompletion, file, line in
                XCTAssertEqual(publishedCompletion, .finished, file: file, line: line)
            },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishesAtLeast value: Output,
        timeout: Double = 1.0,
        description: String = "Publisher publishes at least one value",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { publishedValues, file, line in
                XCTAssertEqual(publishedValues.first, value, file: file, line: line)
            },
            thenCompletesSatisfying: { _, _, _ in },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishes values: [Output],
        thenFailsWith error: Failure,
        timeout: Double = 1.0,
        description: String = "Publisher publishes values then fails",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: values,
            then: .failure(error),
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyFinishesAfterPublishing values: [Output],
        timeout: Double = 1.0,
        description: String = "Publisher publishes values then finishes",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: values,
            then: .finished,
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
        description: String = "Publisher publishes values then completes",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { publishedValues, file, line in
                XCTAssertEqual(publishedValues, values, file: file, line: line)
            },
            thenCompletesSatisfying: { publishedCompletion, file, line in
                guard let completion = completion else { return }
                XCTAssertEqual(publishedCompletion, completion, file: file, line: line)
            },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishes values: [Output],
        timeout: Double = 1.0,
        description: String = "Publisher publishes values",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishes: values,
            then: .none,
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyFailsWith error: Failure,
        timeout: Double = 1.0,
        description: String = "Publisher completes with failure",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { _, _, _ in },
            thenCompletesSatisfying: { publishedCompletion, file, line in
                XCTAssertEqual(publishedCompletion, .failure(error), file: file, line: line)
            },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    func assert<Output, Failure>(
        publisherEventuallyFinishes publisher: AnyPublisher<Output, Failure>,
        timeout: Double = 1.0,
        description: String = "Publisher completes successfully",
        file: StaticString = #file,
        line: UInt = #line
    ) where Output: Equatable, Failure: Equatable & Error {
        assert(
            publisher,
            eventuallyPublishesValuesSatisfying: { _, _, _ in },
            thenCompletesSatisfying: { publishedCompletion, file, line in
                XCTAssertEqual(publishedCompletion, .finished)
            },
            timeout: timeout,
            description: description,
            file: file,
            line: line
        )
    }

    private func assert<Output, Failure>(
        _ publisher: AnyPublisher<Output, Failure>,
        eventuallyPublishesValuesSatisfying valueAssertions: @escaping ([Output], StaticString, UInt) -> Void,
        thenCompletesSatisfying completionAssertions: @escaping (Subscribers.Completion<Failure>?, StaticString, UInt) -> Void,
        timeout: Double = 1.0,
        description: String = "Publisher publishes values and completion satisfying given criteria",
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

        valueAssertions(publication.values, file, line)
        completionAssertions(publication.completion, file, line)
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
