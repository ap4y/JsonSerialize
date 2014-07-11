typealias JsonArray  = [Json]
typealias JsonObject = Dictionary<Swift.String, Json>

enum Json {
    case Number(Double)
    case String(Swift.String)
    case Boolean(Bool)
    case Array(JsonArray)
    case Object(JsonObject)
    case Null

    var object: JsonObject? {
        switch self {
        case let .Object(object):
            return object
        default:
            return nil
        }
    }

    func toString() -> Swift.String {
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
            return result.substringToIndex(countElements(result) - 1) + "]"
        case let .Object(object):
            var result = "{"
            for (key, value) in object {
                result += "\"\(key)\":\(value.toString()),"
            }
            return result.substringToIndex(countElements(result) - 1) + "}"
        case .Null:
            return "null"
        }
    }
}
