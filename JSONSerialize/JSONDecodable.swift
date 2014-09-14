public protocol JSONDecodable {
    class func decode(decoder: JSONDecoder) -> Self?
}

extension Int: JSONDecodable {
    public static func decode(decoder: JSONDecoder) -> Int? {
        switch decoder.pop() {
        case let .Number(number):
            return Int(number)
        default:
            return nil
        }
    }
}

extension Double: JSONDecodable {
    public static func decode(decoder: JSONDecoder) -> Double? {
        switch decoder.pop() {
        case let .Number(number):
            return number
        default:
            return nil
        }
    }
}

extension String: JSONDecodable {
    public static func decode(decoder: JSONDecoder) -> String? {
        switch decoder.pop() {
        case let .String(string):
            return string
        default:
            return nil
        }
    }
}

extension Bool: JSONDecodable {
    public static func decode(decoder: JSONDecoder) -> Bool? {
        switch decoder.pop() {
        case let .Number(number):
            return Bool(number)
        default:
            return nil
        }
    }
}

extension NSDate: JSONDecodable {
    public class func decode(decoder: JSONDecoder) -> Self? {
        switch decoder.pop() {
        case let .Number(interval):
            return self(timeIntervalSince1970: interval)
        default:
            return nil
        }
    }
}
