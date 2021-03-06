//
//  JSONSerializeTests.swift
//  JSONSerializeTests
//
//  Created by ap4y on 11/07/14.
//  Copyright (c) 2014 ap4y. All rights reserved.
//

import XCTest
import JSONSerialize

class TestSubStruct: ToJSON, JSONDecodable {
    let foo = "bar"

    required init(foo: String) {
        self.foo = foo
    }

    func toJSON() -> JSON {
        return JSON.Object(["foo": foo.toJSON()])
    }

    class func decode(decoder: JSONDecoder) -> Self? {
        return decoder.readObject { [unowned decoder] in
            self(foo: decoder.readValueForKey("foo")!)
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
        let expected = "{\"bool\":true,\"date\":0.0,\"sub\":{\"foo\":\"bar\"}," +
                       "\"array\":[\"foo\"],\"dict\":{\"foo\":\"bar\"}," +
                       "\"float\":123.0,\"string\":\"foo\",\"null\":null,\"int\":123.0}"
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

    func testJSONDecodeNested() {
        let jsonString = "{\"nested\":{\"foo\":\"bar\"}}"

        let decoder = JSONDecoder(jsonString: jsonString)
        let decoded: TestSubStruct = decoder.readValueForKey("nested")!

        XCTAssert(decoded.foo == "bar", "Invalid value")
    }
}
