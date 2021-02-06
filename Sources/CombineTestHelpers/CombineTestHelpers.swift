import Combine
import XCTest

public extension XCTestCase {

    func doesThisCompile() -> AnyPublisher<Int, Error> {
        Result<Int, Error>.success(42).publisher.eraseToAnyPublisher()
    }
}
