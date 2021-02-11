# CombineTestHelpers

Custom XCTest assertions that turn this:

```swift
let expectation = XCTestExpectation(description: "Publishes one value then finishes")

var cancellables = Set<AnyCancellable>()
var values = [Int]()

publisher
    .sink(
        receiveCompletion: { completion in
            guard case .finished = completion else { return }
            expectation.fulfill()
        },
        receiveValue: { value in
            guard values.isEmpty else {
                return XCTFail("Expected to receive only one value, got another: (\(value))")
            }
            XCTAssertEqual(value, 42)
            values.append(value)
        }
    )
    .store(in: &cancellables)

wait(for: [expectation], timeout: 0.5)
```

into this:

```swift
assert(publisher, eventuallyFinishesPublishingOnly: 42)
```

---

_To learn more about testing in Swift, checkout my book [Test-Driven Development in Swift with SwiftUI and Combine](https://bit.ly/tdd-in-swift)_.
