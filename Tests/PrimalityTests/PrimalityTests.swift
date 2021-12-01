@testable import Primality
import Subtle
import XCTest

final class PrimalityTests: XCTestCase {
    func testUInt8() {
        XCTAssertEqual((0...UInt8.max)
                        .filter { Bool($0.isPrime) },
                       Primes.under256)
        
        XCTAssertEqual((0...UInt8.max)
                        .filter { Bool($0.isPrime(usingTrialDivisionThrough: 13)) },
                       Primes.under256)
        
        XCTAssertEqual((0...UInt8.max)
                        .filter { Bool($0.isProbablyPrime(withMillerRabinWitnesses: [2])) },
                       Primes.under256)
        
        XCTAssertEqual((0...UInt8.max)
                        .filter(\.isPrimeUsingFastTrialDivision),
                       Primes.under256)
    }
    
    func testUInt16() {
        XCTAssertEqual((0...UInt16.max)
                        .filter { Bool($0.isPrime) },
                       Primes.under65536)
        
        XCTAssertEqual((0...UInt16.max)
                        .filter { Bool($0.isProbablyPrime(withMillerRabinWitnesses: [2, 3])) },
                       Primes.under65536)
    }
    
    // Full-range test would take a few core days.
    // func testUInt32() {
    //     XCTAssert((0...UInt32.max)
    //                 .filter { Bool($0.isPrime) }
    //                 .elementsEqual((2...UInt32.max).filter(\.isPrimeUsingFastTrialDivision)))
    // }
    
    func testUInt32Stochastically() {
        for _ in 0..<256 {
            var rng = SystemRandomNumberGenerator()
            let number: UInt32 = rng.next()
            XCTAssertEqual(Bool(number.isPrime), number.isPrimeUsingFastTrialDivision)
        }
    }
    
    func testUInt64Stochastically() {
        for _ in 0..<16 {
            var rng = SystemRandomNumberGenerator()
            let number: UInt64 = rng.next()
            XCTAssertEqual(Bool(number.isPrime), number.isPrimeUsingFastTrialDivision)
        }
    }
}

fileprivate struct Primes {
    static var under256: [UInt8] = [
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83,
        89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179,
        181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251
    ]
    
    static var under65536: [UInt16] = {
        (2...UInt16.max).filter(\.isPrimeUsingFastTrialDivision)
    }()
}

fileprivate extension FixedWidthInteger where Self: UnsignedInteger {
    var isPrimeUsingFastTrialDivision: Bool {
        guard self > 3 else {
            return self > 1
        }
        
        guard !self.isMultiple(of: 2),
              !self.isMultiple(of: 3) else {
            return false
        }
        
        var divisor: Self = 5
        
        while true {
            let squaredDivisor = divisor.multipliedReportingOverflow(by: divisor)
            
            guard !squaredDivisor.overflow, squaredDivisor.partialValue <= self else {
                return true
            }
            
            guard !self.isMultiple(of: divisor + 0),
                  !self.isMultiple(of: divisor + 2) else {
                return false
            }
            
            divisor += 6
        }
    }
}
