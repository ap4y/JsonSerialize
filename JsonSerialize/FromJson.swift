public protocol FromJSON {
    class func fromJSON(value: JSON) -> Self?
}

extension Int: FromJSON {
    public static func fromJSON(value: JSON) -> Int? {
        switch value {
        case let .Number(number):
            return Int(number)
        default:
            return nil
        }
    }
}

extension Double: FromJSON {
    public static func fromJSON(value: JSON) -> Double? {
        switch value {
        case let .Number(number):
            return number
        default:
            return nil
        }
    }
}

extension String: FromJSON {
    public static func fromJSON(value: JSON) -> String? {
        switch value {
        case let .String(string):
            return string
        default:
            return nil
        }
    }
}

extension Bool: FromJSON {
    public static func fromJSON(value: JSON) -> Bool? {
        switch value {
        case let .Number(number):
            return Bool(number)
        default:
            return nil
        }
    }
}

extension NSDate: FromJSON {
    public class func fromJSON(value: JSON) -> NSDate? {
        switch value {
        case let .Number(interval):
            return NSDate(timeIntervalSince1970: interval)
        default:
            return nil
        }
    }
}
