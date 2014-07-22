public protocol ToJSON {
    func toJSON() -> JSON
}

extension Int: ToJSON {
    public func toJSON() -> JSON {
        return JSON.Number(Double(self))
    }
}

extension Double: ToJSON {
    public func toJSON() -> JSON {
        return JSON.Number(self)
    }
}

extension String: ToJSON {
    public func toJSON() -> JSON {
        return JSON.String(self)
    }
}

extension Bool: ToJSON {
    public func toJSON() -> JSON {
        return JSON.Boolean(self)
    }
}

extension NSDate: ToJSON {
    public func toJSON() -> JSON {
        return JSON.Number(timeIntervalSince1970)
    }
}

extension JSON {
    public static func fromArray<T: ToJSON>(array: [T]) -> JSON {
        return JSON.Array(array.map { $0.toJSON() })
    }

    public static func fromDictionary<K, V: ToJSON>(dict: Dictionary<K, V>) -> JSON {
        var result = JSONObject()
        for (key, value) in dict {
            if !(key is Swift.String) { continue }
            result[key as Swift.String] = (value as V).toJSON()
        }

        return JSON.Object(result)
    }

    public static func fromOptional<T: ToJSON>(optional: Optional<T>) -> JSON {
        switch optional {
        case let .Some(value):
            return value.toJSON()
        case .None:
            return .Null
        }
    }
}
