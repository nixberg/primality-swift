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
                        .filter { Bool($0.isPrime(withMillerWitnesses: [2])) },
                       Primes.under256)
        
        XCTAssertEqual((0...UInt8.max)
                        .filter(\.isPrimeUsingFastTrialDivision),
                       Primes.under256)
        
        XCTAssertEqual((0...UInt8.max)
                        .filter { Bool($0.isPrime(fastWithMillerWitnesses: [2])) },
                       Primes.under256)
    }
    
    func testUInt16() {
        XCTAssertEqual((0...UInt16.max)
                        .filter { Bool($0.isPrime) },
                       Primes.under65536)
        
        XCTAssertEqual((0...UInt16.max)
                        .filter { Bool($0.isPrime(withMillerWitnesses: [2, 3])) },
                       Primes.under65536)
        
        XCTAssertEqual((0...UInt16.max)
                        .filter { Bool($0.isPrime(fastWithMillerWitnesses: [2, 3])) },
                       Primes.under65536)
    }
    
    func testUInt32Prefix() {
        XCTAssertEqual((0...UInt32(UInt16.max))
                        .filter { Bool($0.isPrime) },
                       Primes.under65536.map(UInt32.init))
    }
    
    func testUInt32Stochastically() {
        for _ in 0..<1024 {
            var rng = SystemRandomNumberGenerator()
            let number: UInt32 = rng.next()
            XCTAssertEqual(Bool(number.isPrime), number.isPrimeUsingFastHashing)
        }
    }
    
    func testUInt64Prefix() {
        XCTAssertEqual((0...UInt64(UInt16.max))
                        .filter { Bool($0.isPrime) }.count,
                       Primes.under65536.map(UInt64.init).count)
    }
    
    func testUInt64Stochastically() {
        for _ in 0..<32 {
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
