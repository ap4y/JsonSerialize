JsonSerialize
=============

Encode and Decode `Swift` objects to `JSON` in safe way.

## Synopsis

As with many `Foundation` API, `NSJSONSerialization` returns untyped dictionary. Dictionary conversion to the object will involve significant amount of operations with optionals. Untyped dictionary doesn't help in this situation.

By leveraging the power of `protocols`, `enums` and `generics` this small framework preserves (and recovers) type information during marshalling. As a result type check operations and dictionary parsing can be omitted in many situations.

## Example

```swift
class TestSubStruct: ToJSON, FromJSON {
    let foo = "bar"

    init(foo: String) {
        self.foo = foo
    }

    func toJSON() -> JSON {
        return JSON.Object(["foo": foo.toJSON()])
    }

    class func fromJSON(json: JSON) -> TestSubStruct? {
        let decoder = JSONDecoder(json: json)
        if let value: String = decoder.readValue("foo") {
            return TestSubStruct(foo: value)
        }
        return nil
    }
}

class TestStruct: ToJSON, FromJSON {
    let int    = 123
    let float  = 123.0
    let string = "foo"
    let bool   = true
    let array  = ["foo"]
    var dict   = ["foo": "bar"]
    var sub    = TestSubStruct(foo: "bar")
    var date   = NSDate(timeIntervalSince1970: 0)

    init() {}
    init(json: JSON) {
        let decoder = JSONDecoder(json: json)
        int    = decoder.readValue("int")!
        float  = decoder.readValue("float")!
        string = decoder.readValue("string")!
        bool   = decoder.readValue("bool")!
        array  = decoder.readArray("array")!
        dict   = decoder.readDictionary("dict")!
        sub    = decoder.readValue("sub")!
        date   = decoder.readValue("date")!
    }

    func toJSON() -> JSON {
        let json = [
            "int":    int.toJSON(),
            "float":  float.toJSON(),
            "string": string.toJSON(),
            "bool":   bool.toJSON(),
            "array":  JSON.fromArray(array),
            "dict":   JSON.fromDictionary(dict),
            "sub":    sub.toJSON(),
            "null":   JSON.Null,
            "date":   date.toJSON()
        ]
        return JSON.Object(json)
    }

    class func fromJSON(value: JSON) -> TestStruct? {
        return value.object ? TestStruct(json: value) : nil
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
        XCTAssert(JSON.fromOptional(test).toString() == "null", "Should be Null")

        test = 10
        XCTAssert(JSON.fromOptional(test).toString() == "10.0", "Should be 10.0")
    }

    func testJSONDecode() {
        let jsonString = "{\"int\":321.0,\"bool\":false,\"date\":0," +
                         "\"array\":[\"bar\"],\"dict\":{\"bar\":\"baz\"}," +
                         "\"float\":321.0,\"string\":\"bar\",\"sub\":{\"foo\":\"bar\"}}"

        let json = JSON.jsonWithJSONString(jsonString)
        let decoded = TestStruct(json: json)

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
