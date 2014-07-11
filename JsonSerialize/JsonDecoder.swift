import Foundation

class JsonDecoder {

    let json: Json

    init(json: Json) {
        self.json = json
    }

    init(jsonString: String) {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        let dict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)

        json = JsonDecoder.jsonWithAnyObject(dict)
    }

    class func jsonWithAnyObject(json: AnyObject!) -> Json {
        if !json { return .Null }

        switch json! {
        case let number as NSNumber:
            if number.objCType == "c" { return .Boolean(number.boolValue) }
            return .Number(number.doubleValue)
        case let string as NSString:
            return .String(string)
        case let array as NSArray:
            var result = JsonArray()
            for item in array {
                result.append(jsonWithAnyObject(item))
            }
            return .Array(result)
        case let dict as NSDictionary:
            var result = JsonObject()
            for (key, value) in dict {
                if !(key is Swift.String) { continue }
                result[key as Swift.String] = jsonWithAnyObject(value)
            }
            return .Object(result)
        default:
            return .Null
        }
    }

    func readValue<T: FromJson>(key: String) -> T? {
        if let value = json.object?[key] {
            return T.fromJson(value)
        }

        return nil
    }

    func readArray<T: FromJson>(key: String) -> [T]? {
        if let value = json.object?[key] {
            switch value {
            case let .Array(array):
                var result = [T]()
                for item in array {
                    if let item = T.fromJson(item) { result.append(item) }
                }
                return result
            default:
                return nil
            }
        }

        return nil
    }

    func readDictionary<V: FromJson>(key: String) -> [String: V]? {
        if let value = json.object?[key] {
            switch value {
            case let .Object(object):
                var result = Dictionary<String, V>()
                for (key, item) in object {
                    if let value = V.fromJson(item) {
                        result[key as String] = value
                    }
                }
                return result
            default:
                return nil
            }
        }

        return nil
    }
}
