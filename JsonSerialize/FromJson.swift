protocol FromJson {
    class func fromJson(value: Json) -> Self?
}

extension Int: FromJson {
    static func fromJson(value: Json) -> Int? {
        switch value {
        case let .Number(number):
            return Int(number)
        default:
            return nil
        }
    }
}

extension Double: FromJson {
    static func fromJson(value: Json) -> Double? {
        switch value {
        case let .Number(number):
            return number
        default:
            return nil
        }
    }
}

extension String: FromJson {
    static func fromJson(value: Json) -> String? {
        switch value {
        case let .String(string):
            return string
        default:
            return nil
        }
    }
}

extension Bool: FromJson {
    static func fromJson(value: Json) -> Bool? {
        switch value {
        case let .Boolean(bool):
            return bool
        default:
            return nil
        }
    }
}

extension NSDate: FromJson {
    class func fromJson(value: Json) -> NSDate? {
        switch value {
        case let .Number(interval):
            return NSDate(timeIntervalSince1970: interval)
        default:
            return nil
        }
    }
}
