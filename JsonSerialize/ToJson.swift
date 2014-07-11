protocol ToJson {
    func toJson() -> Json
}

extension Int: ToJson {
    func toJson() -> Json {
        return Json.Number(Double(self))
    }
}

extension Double: ToJson {
    func toJson() -> Json {
        return Json.Number(self)
    }
}

extension String: ToJson {
    func toJson() -> Json {
        return Json.String(self)
    }
}

extension Bool: ToJson {
    func toJson() -> Json {
        return Json.Boolean(self)
    }
}


extension Json {
    static func fromArray<T: ToJson>(array: [T]) -> Json {
        return Json.Array(array.map { $0.toJson() })
    }

    static func fromDictionary<K, V: ToJson>(dict: Dictionary<K, V>) -> Json {
        var result = JsonObject()
        for (key, value) in dict {
            if !(key is Swift.String) { continue }
            result[key as Swift.String] = (value as V).toJson()
        }

        return Json.Object(result)
    }

    static func fromOptional<T: ToJson>(optional: Optional<T>) -> Json {
        switch optional {
        case let .Some(value):
            return value.toJson()
        case .None:
            return .Null
        }
    }
}
