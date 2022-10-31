import Foundation

extension String {

    var isBlank: Bool {
        trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }

    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var isFullName: Bool {
        // https://andrewwoods.net/blog/2018/name-validation-regex/#toc_11
        let fullNameRegEx = #"^[A-Za-z\x{00C0}-\x{00FF}\x{0400}-\x{04FF}][A-Za-z\x{00C0}-\x{00FF}\x{0400}-\x{04FF}\'\-]+([\ A-Za-z\x{00C0}-\x{00FF}\x{0400}-\x{04FF}][A-Za-z\x{00C0}-\x{00FF}\x{0400}-\x{04FF}\'\-]+)*"#
//        let fullNameRegEx = #"^[A-Za-z][A-Za-z\'\-]+([\ A-Za-z][A-Za-z\'\-]+)*"#
        let fullNameTest = NSPredicate(format: "SELF MATCHES %@", fullNameRegEx)
        return fullNameTest.evaluate(with: self)
    }

    var isValidPassword: Bool {
        let passwordRegEx = "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }

    var isValidEmailAddress: Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var isValidPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
