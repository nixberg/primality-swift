import Subtle

public extension UInt8 {
    var isPrime: Choice {
        let isLessThan064: Choice = self <  64
        let isLessThan128: Choice = self < 128
        let isLessThan192: Choice = self < 192
        
        let isInRangeA =                   isLessThan064
        let isInRangeB = !isLessThan064 && isLessThan128
        let isInRangeC = !isLessThan128 && isLessThan192
        let isInRangeD = !isLessThan192
        
        let a: UInt64 = (1 << (.init(self) &-   0)) & 0x28208a20a08a28ac
        let b: UInt64 = (1 << (.init(self) &-  64)) & 0x800228a202088288
        let c: UInt64 = (1 << (.init(self) &- 128)) & 0x8028208820a00a08
        let d: UInt64 = (1 << (.init(self) &- 192)) & 0x08028228800800a2
        
        let isPrimeA = isInRangeA && a != 0
        let isPrimeB = isInRangeB && b != 0
        let isPrimeC = isInRangeC && c != 0
        let isPrimeD = isInRangeD && d != 0
        
        return isPrimeA || isPrimeB || isPrimeC || isPrimeD
    }
}

public extension UInt16 {
    var isPrime: Choice {
        self.isPrime(usingTrialDivisionThrough: 251)
    }
}

public extension UInt32 {
    var isPrime: Choice {
        self.isProbablyPrime(withMillerWitnesses: [2, 7, 61])
    }
}

public extension UInt64 {
    var isPrime: Choice {
        self.isProbablyPrime(withMillerWitnesses: [
            2, 325, 9375, 28178, 450775, 9780504, 1795265022
        ])
    }
}

extension FixedWidthInteger
where
    Self: UnsignedInteger,
    Self: ConditionallyReplaceable,
    Self: ConstantTimeGreaterThanOrEqualTo & ConstantTimeLessThanOrEqualTo
{
    func isPrime(usingTrialDivisionThrough end: Self) -> Choice {
        (self == 2) || (self == 3) || [
            self > 3,
            self % 2 != 0,
            self % 3 != 0,
            !self.isComposite(usingTrialDivisionThrough: end)
        ].reduce(.true, &&)
    }
    
    private func isComposite(usingTrialDivisionThrough end: Self) -> Choice {
        // assert(self > 3)
        // assert(!self.isMultiple(of: 2))
        // assert(!self.isMultiple(of: 3))
        
        stride(from: 5, through: end, by: 6).reduce(.false) {
            var isComposite: Choice = .false
            
            isComposite ||= self % ($1 + 0) == 0
            isComposite ||= self % ($1 + 2) == 0
            isComposite &&= $1 * $1 <= self
            
            return $0 || isComposite
        }
    }
    
    func isProbablyPrime(withMillerWitnesses witnesses: [Self]) -> Choice {
        let isGreaterThanTwo: Choice = self > 2
        let isOdd: Choice = self % 2 != 0
        return (self == 2) || [
            isGreaterThanTwo,
            isOdd,
            !self.replaced(with: 3, if: !(isGreaterThanTwo && isOdd))
                .isComposite(withMillerWitnesses: witnesses)
        ].reduce(.true, &&)
    }
    
    private func isComposite(withMillerWitnesses witnesses: [Self]) -> Choice {
        assert(self > 1)
        assert(!self.isMultiple(of: 2))
        
        let k = Self(truncatingIfNeeded: (self &- 1).trailingZeroBitCount)
        let q = self &>> k
        
        assert(!q.isMultiple(of: 2))
        assert((1 << k) * q + 1 == self)
        
        return witnesses.reduce(.false) {
            // See https://miller-rabin.appspot.com/#remarks
            
            var witness = $1 % self
            var isComposite: Choice = witness != 0
            
            witness = pow(witness, q, modulo: self)
            isComposite &&= witness != 1
            
            return $0 || Self.bits.reduce(into: isComposite) {
                $0 &&= (witness != self &- 1) || ($1 >= k)
                witness.square(modulo: self)
            }
        }
    }
}

fileprivate func pow<T>(_ base: T, _ exponent: T, modulo modulus: T) -> T
where T: FixedWidthInteger & UnsignedInteger & ConditionallyReplaceable {
    T.bits.reversed().reduce(into: (1, base % modulus)) {
        let shouldSwap: Choice = exponent & (1 &<< $1) == 0
        $0.0.swap(with: &$0.1, if: shouldSwap)
        $0.0 = modulus.dividingFullWidth($0.1.multipliedFullWidth(by: $0.0)).remainder
        $0.1 = modulus.dividingFullWidth($0.1.multipliedFullWidth(by: $0.1)).remainder
        $0.0.swap(with: &$0.1, if: shouldSwap)
    }.0
}

fileprivate extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    mutating func square(modulo modulus: Self) {
        self = modulus.dividingFullWidth(self.multipliedFullWidth(by: self)).remainder
    }
}

fileprivate extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    static var bits: Range<Self> {
        0..<Self(Self.bitWidth)
    }
}
