public class JSONDecoder {

    let json: JSON

    public init(json: JSON) {
        self.json = json
    }

    public init(jsonString: String) {
        json = JSON.jsonWithJSONString(jsonString)
    }

    public func readValue<T: FromJSON>(key: String) -> T? {
        if let value = json.object?[key] {
            return T.fromJSON(value)
        }

        return nil
    }

    public func readArray<T: FromJSON>(key: String) -> [T]? {
        if let value = json.object?[key] {
            switch value {
            case let .Array(array):
                var result = [T]()
                for item in array {
                    if let item = T.fromJSON(item) { result.append(item) }
                }
                return result
            default:
                return nil
            }
        }

        return nil
    }

    public func readDictionary<V: FromJSON>(key: String) -> [String: V]? {
        if let value = json.object?[key] {
            switch value {
            case let .Object(object):
                var result = Dictionary<String, V>()
                for (key, item) in object {
                    if let value = V.fromJSON(item) {
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
