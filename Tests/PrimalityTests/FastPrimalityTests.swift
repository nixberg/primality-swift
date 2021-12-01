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
