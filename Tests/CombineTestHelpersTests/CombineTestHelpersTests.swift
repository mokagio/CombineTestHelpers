import Combine
@testable import CombineTestHelpers
import XCTest

final class CombineTestHelpersTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    /*
     Possible scenarios:

     values \ completion    | failure   | finished  | unknown
     ---------------------------------------------------------
     no value               | 1         | 2         | 3
     at least one value     | 4         | 5         | 6
     exactly one value      | 7         | 8         | 9
     many values            | 10        | 11        | 12
     unknown                | 13        | 14        | n.a.

     */

    /// 1 - values: none & completion: failure
    func test1() {
        let publisher = makePublisher {
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, publishesNoValueThenFailsWith: .errorCase1)
    }

    /// 2 - values: none & completion: finished
    func test2() {
        let publisher = makePublisher {
            $0.send(completion: .finished)
        }

        assert(publisherPublishesNoValueThenFinishes: publisher)
    }

    /// 3 - values: none & completion: unknown
    func test3a() {
        let publisher = makePublisher {
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisherPublishesNoValue: publisher)
    }

    func test3b() {
        let publisher = makePublisher {
            $0.send(completion: .finished)
        }

        assert(publisherPublishesNoValue: publisher)
    }

    /// 4 - values: at least one & completion: failure
    func test4() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishesAtLeast: 1, thenFailsWith: .errorCase1)
    }

    /// 5 - values: at least one & completion: finished
    func test5() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyFinishesPublishingAtLeast: 1)
    }

    /// 6 - values: at least one & completion: unknown
    func test6a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishesAtLeast: 1)
    }

    func test6b() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyPublishesAtLeast: 1)
    }

    /// 7 - values: exactly one & completion: failure
    func test7() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishesOnly: 1, thenFailsWith: .errorCase1)
    }

    /// 8 - values: exactly one & completion: finished
    func test8plus() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyFinishesPublishingOnly: 1)
    }

    /// 9 - values: exactly one & completion: unknown
    func test9a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishesOnly: 1)
    }

    func test9b() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyPublishesOnly: 1)
    }

    /// 10 - values: many & completion: failure

    /// 11 - values: many & completion: finished

    /// 12 - values: many & completion: unknown

    /// 13 - values: unknown & completion: failure

    /// 14 - values: unknown & completion: finished

    private func makePublisher(
        _ subjectBehavior: @escaping (PassthroughSubject<Int, TestError>) -> Void
    ) -> AnyPublisher<Int, TestError> {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) { subjectBehavior(subject) }
        return subject.eraseToAnyPublisher()
    }

    func testFirstPublishedValue() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(completion: .finished)
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "First published value is 1")

        publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    XCTAssertEqual($0, 1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testPublishesOnlyOneValue() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(completion: .finished)
        }

        assert(subject.eraseToAnyPublisher(), eventuallyPublishesOnly: 1)
    }

    func testPublishesOnlyOneValueThenFails() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(completion: .failure(.errorCase1))
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(
            description: "Publishes only once with value 1 then fails"
        )

        publisher
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    XCTAssertEqual(error, .errorCase1)
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual($0, 1)
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testPublishesManyValues() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .finished)
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Publishes many values")

        var values: [Int] = []

        publisher
            .sink(
                receiveCompletion: { completion in
                    guard case .finished = completion else { return }
                    expectation.fulfill()
                },
                receiveValue: {
                    values.append($0)
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual([1,2,3], values)
    }

    func testEventuallyPublishesAFailure() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .failure(.errorCase1))
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Eventually publishes a failure")

        publisher
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    XCTAssertEqual(.errorCase1, error)
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testPublishesOnlyFailure() {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(completion: .failure(.errorCase1))
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Fails without publishing values")

        publisher
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    XCTAssertEqual(error, .errorCase1)
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTFail("Expected to fail without receiving any value, got \($0)")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testPublishesSomeValuesThenFails() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .failure(.errorCase2))
        }

        assert(
            subject.eraseToAnyPublisher(),
            eventuallyPublishes: [1, 2, 3],
            then: .failure(.errorCase2)
        )
    }

    // The difference here is that we use an array of `Result` to collect all the values and then
    // run an equality assertion on that. It only works if both `Output` and `Failure` conform to
    // `Equatable`
    func testPublishesSomeValuesThenFails_Alternative() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .failure(.errorCase2))
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Publishes values then a failure")

        var values: [Result<Int, TestError>] = []

        publisher
            .sink(
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

        wait(for: [expectation], timeout: 0.5)

        let expectedValues: [Result<Int, TestError>] = [
            .success(1), .success(2), .success(3), .failure(.errorCase2)
        ]
        XCTAssertEqual(expectedValues, values)
    }

    // TODO: Is there a way to generate this at runtime to include all the methods starting with
    // tests instead of manually update it?
    static var allTests = [
        ("testFirstPublishedValue", testFirstPublishedValue),
        ("testPublishesOnlyOneValue", testPublishesOnlyOneValue),
        ("testPublishesManyValues", testPublishesManyValues),
        ("testEventuallyPublishesAFailure", testEventuallyPublishesAFailure),
        ("testPublishesOnlyFailure", testPublishesOnlyFailure),
        ("testPublishesSomeValuesThenFails", testPublishesSomeValuesThenFails),
    ]
}
