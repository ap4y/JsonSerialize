public protocol ToJson {
    func toJson() -> Json
}

extension Int: ToJson {
    public func toJson() -> Json {
        return Json.Number(Double(self))
    }
}

extension Double: ToJson {
    public func toJson() -> Json {
        return Json.Number(self)
    }
}

extension String: ToJson {
    public func toJson() -> Json {
        return Json.String(self)
    }
}

extension Bool: ToJson {
    public func toJson() -> Json {
        return Json.Boolean(self)
    }
}

extension NSDate: ToJson {
    public func toJson() -> Json {
        return Json.Number(timeIntervalSince1970)
    }
}

extension Json {
    public static func fromArray<T: ToJson>(array: [T]) -> Json {
        return Json.Array(array.map { $0.toJson() })
    }

    public static func fromDictionary<K, V: ToJson>(dict: Dictionary<K, V>) -> Json {
        var result = JsonObject()
        for (key, value) in dict {
            if !(key is Swift.String) { continue }
            result[key as Swift.String] = (value as V).toJson()
        }

        return Json.Object(result)
    }

    public static func fromOptional<T: ToJson>(optional: Optional<T>) -> Json {
        switch optional {
        case let .Some(value):
            return value.toJson()
        case .None:
            return .Null
        }
    }
}
