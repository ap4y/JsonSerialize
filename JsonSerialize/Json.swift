public typealias JSONArray  = [JSON]
public typealias JSONObject = Dictionary<Swift.String, JSON>

public enum JSON {
    case Number(Double)
    case String(Swift.String)
    case Boolean(Bool)
    case Array(JSONArray)
    case Object(JSONObject)
    case Null

    public var object: JSONObject? {
        switch self {
        case let .Object(object):
            return object
        default:
            return nil
        }
    }

    public static func jsonWithJSONString(jsonString: Swift.String) -> JSON {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let opts = NSJSONReadingOptions(0)
        let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: opts, error: nil)

        return jsonWithAnyObject(json);
    }
    public static func jsonWithAnyObject(json: AnyObject!) -> JSON {
        if !json { return .Null }

        switch json! {
        case let number as NSNumber:
            return .Number(number.doubleValue)
        case let string as NSString:
            return .String(string)
        case let array as NSArray:
            var result = JSONArray()
            for item in array {
                result.append(jsonWithAnyObject(item))
            }
            return .Array(result)
        case let dict as NSDictionary:
            var result = JSONObject()
            for (key, value) in dict {
                if !(key is Swift.String) { continue }
                result[key as Swift.String] = jsonWithAnyObject(value)
            }
            return .Object(result)
        default:
            return .Null
        }
    }

    public func toString() -> Swift.String {
        switch self {
        case let .Number(number):
            return "\(number)"
        case let .String(string):
            return "\"\(string)\""
        case let .Boolean(bool):
            return "\(bool)"
        case let .Array(array):
            var result = "["
            for item in array { result += "\(item.toString())," }
            return result[result.startIndex..<advance(result.endIndex, -1)] + "]"
        case let .Object(object):
            var result = "{"
            for (key, value) in object {
                result += "\"\(key)\":\(value.toString()),"
            }
            return result[result.startIndex..<advance(result.endIndex, -1)] + "}"
        case .Null:
            return "null"
        }
    }
}
