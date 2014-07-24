public class JSONDecoder {
    let json: JSON
    var stack: [JSON]

    public init(json: JSON) {
        self.json = json
        stack = [json]
    }

    public init(jsonString: String) {
        json = JSON.jsonWithJSONString(jsonString)
        stack = [json]
    }

    public func pop() -> JSON {
        return stack[stack.endIndex]
    }

    public func readValue<T: JSONDecodable>(key: String) -> T? {
        if let value = json.object?[key] {
            stack.append(value)
            return T.decode(self)
        }

        return nil
    }

    public func readArray<T: JSONDecodable>(key: String) -> [T]? {
        if let value = json.object?[key] {
            switch value {
            case let .Array(array):
                var result = [T]()
                for item in array {
                    stack.append(value)
                    if let item = T.decode(self) { result.append(item) }
                }
                return result
            default:
                return nil
            }
        }

        return nil
    }

    public func readDictionary<V: JSONDecodable>(key: String) -> [String: V]? {
        if let value = json.object?[key] {
            switch value {
            case let .Object(object):
                var result = Dictionary<String, V>()
                for (key, item) in object {
                    stack.append(item)
                    if let value = V.decode(self) {
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