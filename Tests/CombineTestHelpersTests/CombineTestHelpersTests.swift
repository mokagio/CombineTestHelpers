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
    func test8() {
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
    func test10a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishes: [1, 2], thenFailsWith: .errorCase1)
    }

    func test10b() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishes: [1, 2], then: .failure(.errorCase1))
    }

    /// 11 - values: many & completion: finished
    func test11a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyFinishesAfterPublishing: [1, 2])
    }

    func test11b() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyPublishes: [1, 2], then: .finished)
    }

    /// 12 - values: many & completion: unknown
    func test12a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyPublishes: [1, 2])
    }

    func test12b() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(2)
            $0.send(completion: .finished)
        }

        assert(publisher, eventuallyPublishes: [1, 2])
    }

    /// 13 - values: unknown & completion: failure
    func test13a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyFailsWith: .errorCase1)
    }

    func test13b() {
        let publisher = makePublisher {
            $0.send(completion: .failure(.errorCase1))
        }

        assert(publisher, eventuallyFailsWith: .errorCase1)
    }

    /// 14 - values: unknown & completion: finished
    func test14a() {
        let publisher = makePublisher {
            $0.send(1)
            $0.send(completion: .finished)
        }

        assert(publisherEventuallyFinishes: publisher)
    }

    func test14b() {
        let publisher = makePublisher {
            $0.send(completion: .finished)
        }

        assert(publisherEventuallyFinishes: publisher)
    }

    private func makePublisher(
        _ subjectBehavior: @escaping (PassthroughSubject<Int, TestError>) -> Void
    ) -> AnyPublisher<Int, TestError> {
        let subject = PassthroughSubject<Int, TestError>()
        asyncAfter(0.1) { subjectBehavior(subject) }
        return subject.eraseToAnyPublisher()
    }

    // TODO: Is there a way to generate this at runtime to include all the methods starting with
    // tests instead of manually update it?
    static var allTests = [
        ("test1", test1),
        ("test2", test2),
        ("test3a", test3a),
        ("test3b", test3b),
        ("test4", test4),
        ("test5", test5),
        ("test6a", test6a),
        ("test6b", test6b),
        ("test7", test7),
        ("test8", test8),
        ("test9a", test9a),
        ("test9b", test9b),
        ("test10a", test10a),
        ("test10b", test10b),
        ("test11a", test11a),
        ("test11b", test11b),
        ("test12a", test12a),
        ("test12b", test12b),
        ("test13a", test13a),
        ("test13b", test13b),
        ("test14a", test14a),
        ("test14b", test14b),
    ]
}
