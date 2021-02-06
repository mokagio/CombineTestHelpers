import Combine
@testable import CombineTestHelpers
import XCTest

final class CombineTestHelpersTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

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

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Publishes only once with value 1")

        publisher
            .sink(
                receiveCompletion: { completion in
                    guard case .finished = completion else { return }
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual($0, 1)
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 0.5)
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


    // Similar to the previous one, but now we're interested in the published values, too.
    func testPublishesSomeValuesThenFails() throws {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .failure(.errorCase2))
        }

        let publisher = subject.eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Publishes values then a failure")

        var values: [Int] = []

        publisher.sink(
            receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                XCTAssertEqual(.errorCase2, error)
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
