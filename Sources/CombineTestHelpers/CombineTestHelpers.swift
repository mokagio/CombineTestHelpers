import Combine
import XCTest

extension XCTestCase {

    func doesThisCompile() -> AnyPublisher<Int, Error> {
        Result<Int, Error>.success(42).publisher.eraseToAnyPublisher()
    }
}
