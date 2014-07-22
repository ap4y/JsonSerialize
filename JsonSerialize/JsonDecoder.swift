import Foundation

class JsonDecoder {

    let json: Json

    init(json: Json) {
        self.json = json
    }

    init(jsonString: String) {
        json = Json.jsonWithJsonString(jsonString)
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
