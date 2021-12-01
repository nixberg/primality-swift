extension FixedWidthInteger where Self: UnsignedInteger {
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

extension UInt32 {
    var isPrimeUsingFastHashing: Bool {
        let bases: [UInt16] = [
            0x04c0, 0x072c, 0x22b5, 0x11d4, 0x2ae2, 0x146c, 0x3cfd, 0x3675,
            0x0611, 0x00ad, 0x0e1f, 0x0c48, 0x2751, 0x242b, 0x00e9, 0x093a,
            0x1864, 0x191f, 0x2a6f, 0x1720, 0x1908, 0x1ab9, 0x566c, 0x08f2,
            0xb21d, 0x1b17, 0x12e3, 0x1de4, 0x041b, 0x01bd, 0x16af, 0x034a,
            0x05fe, 0x567c, 0x0502, 0x06c5, 0x015b, 0x18a7, 0x3701, 0x2b95,
            0x00ba, 0x02bf, 0x2686, 0x3c82, 0x06b8, 0x4598, 0x28c1, 0xc021,
            0x09e7, 0x23c6, 0x085f, 0x0b18, 0x0298, 0x7192, 0x615c, 0x040b,
            0xa20a, 0x0429, 0x27cd, 0x20e1, 0x0082, 0x11c7, 0x1427, 0xbef6,
            0x0312, 0x0792, 0x03f5, 0x085b, 0x1c03, 0x085f, 0x41e9, 0x00bc,
            0x15b3, 0xa417, 0x0415, 0x0f33, 0x0b25, 0x5c5a, 0x0094, 0x0e01,
            0x0bd3, 0x0118, 0x0c1d, 0x26be, 0x1934, 0x0a9c, 0x0357, 0x03de,
            0x0785, 0x34f5, 0x0427, 0x1b04, 0x1365, 0x111c, 0x024b, 0x0c8e,
            0x0710, 0x040c, 0x18d4, 0x1fff, 0x1a7f, 0x3858, 0x1b11, 0x03ea,
            0x0348, 0x01a6, 0xacb7, 0x1e49, 0x16a7, 0x0d57, 0x00e7, 0x07dd,
            0x22bf, 0x0821, 0x0373, 0x0f0f, 0x15c9, 0x036c, 0x0df6, 0x0785,
            0x04a8, 0x0361, 0x1cd0, 0x2fde, 0x1740, 0x09d4, 0x4fef, 0x00ba,
            0x1523, 0x8a19, 0xc6d2, 0x043c, 0x084f, 0x10d1, 0x0073, 0x1e8d,
            0x04f1, 0x3f29, 0x06a9, 0x0741, 0x616a, 0x00dc, 0x0e42, 0x0421,
            0x01e2, 0x069a, 0x0a9e, 0x10d5, 0x1d48, 0x05eb, 0x1f24, 0x0eb3,
            0x2aca, 0x0b01, 0x0d66, 0x058f, 0x02ca, 0x1a4e, 0x0148, 0x0a15,
            0x0a14, 0x273f, 0x0aed, 0x009b, 0x173f, 0x0ee9, 0xd642, 0x087d,
            0x0526, 0x00f6, 0x070f, 0x0b8e, 0x0a89, 0x0151, 0x1307, 0x0987,
            0x02e0, 0x90f8, 0x04ca, 0x020f, 0x1d6b, 0x152a, 0x1c4a, 0x0975,
            0x3f07, 0x1b67, 0x20f0, 0x0a2d, 0x1606, 0x1429, 0x2cfb, 0x3a65,
            0x02ec, 0x138b, 0x2358, 0x1247, 0x077b, 0x1de4, 0x25b9, 0x0294,
            0x0bee, 0x3c6d, 0x0b5e, 0x0307, 0x371a, 0x06d5, 0x0088, 0x0a71,
            0xf176, 0x1601, 0x04dc, 0x0a07, 0x137d, 0x0665, 0x04f9, 0x2c9f,
            0x1f26, 0x1d55, 0x17ad, 0x0213, 0x19d0, 0x0440, 0x065b, 0x00a0,
            0x1910, 0x2c56, 0x0399, 0x0132, 0x46c5, 0x04d6, 0x01cf, 0x06ba,
            0x03e4, 0x0f1a, 0x19b0, 0x17a7, 0x0082, 0x5e10, 0x1ca3, 0x0f52,
            0x21b8, 0x0a92, 0x5e2c, 0x7e76, 0x108d, 0x3bc6, 0x011f, 0x08f8,
            0x04c4, 0x51ba, 0x0d16, 0x0829, 0x0232, 0x2de1, 0x00a3, 0x2eaf,
        ]
        
        let base = bases[Int(truncatingIfNeeded: (0xad625b89 &* self) &>> 24)]
        
        return self.isPrime(fastWithMillerWitnesses: [UInt32(base)])
    }
}

extension FixedWidthInteger where Self: UnsignedInteger {
    func isPrime(fastWithMillerWitnesses witnesses: [Self]) -> Bool {
        if self == 2 {
            return true
        }
        
        guard self > 2, !self.isMultiple(of: 2) else {
            return false
        }
        
        return !self.isComposite(withMillerWitnesses: witnesses)
    }
    
    private func isComposite(withMillerWitnesses witnesses: [Self]) -> Bool {
        assert(self > 1)
        assert(!self.isMultiple(of: 2))
        
        let k = Self(truncatingIfNeeded: (self &- 1).trailingZeroBitCount)
        let q = self &>> k
        
        assert(!q.isMultiple(of: 2))
        assert((1 << k) * q + 1 == self)
        
    witnessLoop: for witness in witnesses {
            var witness = witness % self
            guard witness != 0 else {
                continue
            }
            
            witness = pow(witness, q, modulo: self)
            guard witness != 1 else {
                continue
            }
            
            for _ in 0..<k {
                guard witness != self &- 1 else {
                    continue witnessLoop
                }
                witness.square(modulo: self)
            }
            
            return true
        }
        
        return false
    }
}

fileprivate func pow<T>(_ base: T, _ exponent: T, modulo modulus: T) -> T
where T: FixedWidthInteger & UnsignedInteger {
    T.bits.reversed().reduce(into: (1, base % modulus)) {
        if exponent & (1 &<< $1) == 0 {
            $0.1 = modulus.dividingFullWidth($0.0.multipliedFullWidth(by: $0.1)).remainder
            $0.0 = modulus.dividingFullWidth($0.0.multipliedFullWidth(by: $0.0)).remainder
        } else {
            $0.0 = modulus.dividingFullWidth($0.1.multipliedFullWidth(by: $0.0)).remainder
            $0.1 = modulus.dividingFullWidth($0.1.multipliedFullWidth(by: $0.1)).remainder
        }
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
