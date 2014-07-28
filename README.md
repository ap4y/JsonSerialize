JsonSerialize
=============

Encode and Decode `Swift` objects to `JSON` in safe way.

## Synopsis

As with many `Foundation` API, `NSJSONSerialization` returns untyped dictionary. Dictionary conversion to the object will involve significant amount of operations with optionals. Untyped dictionary doesn't help in this situation.

By leveraging the power of `protocols`, `enums` and `generics` this small framework preserves (and recovers) type information during marshalling. As a result type check operations and dictionary parsing can be omitted in many situations.

## Example

```swift
class TestSubStruct: ToJSON, JSONDecodable {
    let foo = "bar"

    init(foo: String) {
        self.foo = foo
    }

    func toJSON() -> JSON {
        return JSON.Object(["foo": foo.toJSON()])
    }

    class func decode(decoder: JSONDecoder) -> TestSubStruct? {
        return decoder.readObject { [unowned decoder] in
            TestSubStruct(foo: decoder.readValueForKey("foo")!)
        }
    }
}

class TestStruct: ToJSON {
    let int    = 123
    let float  = 123.0
    let string = "foo"
    let bool   = true
    let array  = ["foo"]
    var dict   = ["foo": "bar"]
    var sub    = TestSubStruct(foo: "bar")
    var date   = NSDate(timeIntervalSince1970: 0)

    init() {}
    init(decoder: JSONDecoder) {
        int    = decoder.readValueForKey("int")!
        float  = decoder.readValueForKey("float")!
        string = decoder.readValueForKey("string")!
        bool   = decoder.readValueForKey("bool")!
        array  = decoder.readArrayForKey("array")!
        dict   = decoder.readDictionaryForKey("dict")!
        sub    = decoder.readValueForKey("sub")!
        date   = decoder.readValueForKey("date")!
    }

    func toJSON() -> JSON {
        let json = [
            "int":    int.toJSON(),
            "float":  float.toJSON(),
            "string": string.toJSON(),
            "bool":   bool.toJSON(),
            "array":  JSON.JSONWithArray(array),
            "dict":   JSON.JSONWithDictionary(dict),
            "sub":    sub.toJSON(),
            "null":   JSON.Null,
            "date":   date.toJSON()
        ]
        return JSON.Object(json)
    }
}

class JSONSerializeTests: XCTestCase {

    func testJSONEncode() {
        let testObject = TestStruct()
        let expected = "{\"int\":123.0,\"bool\":true,\"null\":null,\"date\":0.0," +
                       "\"array\":[\"foo\"],\"dict\":{\"foo\":\"bar\"}," +
                       "\"float\":123.0,\"string\":\"foo\",\"sub\":{\"foo\":\"bar\"}}"
        let encoded = testObject.toJSON().toString()
        XCTAssert(encoded == expected, "Invalid JSON: \(encoded)")
    }

    func testJSONEncodeOptional() {
        var test: Int?
        XCTAssert(JSON.JSONWithOptional(test).toString() == "null", "Should be Null")

        test = 10
        XCTAssert(JSON.JSONWithOptional(test).toString() == "10.0", "Should be 10.0")
    }

    func testJSONDecode() {
        let jsonString = "{\"int\":321.0,\"bool\":false,\"date\":0," +
                         "\"array\":[\"bar\"],\"dict\":{\"bar\":\"baz\"}," +
                         "\"float\":321.0,\"string\":\"bar\",\"sub\":{\"foo\":\"bar\"}}"

        let decoder = JSONDecoder(jsonString: jsonString)
        let decoded = TestStruct(decoder: decoder)

        XCTAssert(decoded.int == 321, "Invalid int value")
        XCTAssert(decoded.bool == false, "Invalid bool value")
        XCTAssert(decoded.array == ["bar"], "Invalid array value")
        XCTAssert(decoded.dict == ["bar": "baz"], "Invalid dic value")
        XCTAssert(decoded.float == 321.0, "Invalid float value")
        XCTAssert(decoded.string == "bar", "Invalid string value")
        XCTAssert(decoded.sub.foo == "bar", "Invalid sub value")
        XCTAssert(decoded.date == NSDate(timeIntervalSince1970: 0), "Invalid date value")
    }
}
```

## Credits

Implementation base on `serialize::json` crate from [Rust](http://www.rust-lang.org). If you like `Swift` I may want to check `Rust` too.
