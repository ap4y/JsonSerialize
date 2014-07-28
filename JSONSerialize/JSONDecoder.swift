public class JSONDecoder {
    var stack: [JSON]

    public init(json: JSON) {
        stack = [json]
    }

    public convenience init(jsonString: String) {
        self.init(json: JSON.jsonWithJSONString(jsonString))
    }

    public func readObject<T>(block: () -> T?) -> T? {
        let value = block()
        pop()
        return value
    }

    public func readValueForKey<T: JSONDecodable>(key: String) -> T? {
        let json = stack[stack.endIndex - 1]
        if let value = json.object?[key] {
            stack.append(value)
            return T.decode(self)
        }

        return nil
    }

    public func readArrayForKey<T: JSONDecodable>(key: String) -> [T]? {
        let json = stack[stack.endIndex - 1]
        if let value = json.object?[key] {
            switch value {
            case let .Array(array):
                var result = [T]()
                for item in array {
                    stack.append(item)
                    if let item = T.decode(self) { result.append(item) }
                }
                return result
            default:
                return nil
            }
        }

        return nil
    }

    public func readDictionaryForKey<V: JSONDecodable>(key: String) -> [String: V]? {
        let json = stack[stack.endIndex - 1]
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

    func pop() -> JSON {
        return stack.removeLast()
    }
}
