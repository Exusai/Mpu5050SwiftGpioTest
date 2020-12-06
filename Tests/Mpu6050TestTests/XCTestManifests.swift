import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Mpu6050TestTests.allTests),
    ]
}
#endif
