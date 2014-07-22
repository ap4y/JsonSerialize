//
//  JsonSerializeTests.swift
//  JsonSerializeTests
//
//  Created by ap4y on 11/07/14.
//  Copyright (c) 2014 ap4y. All rights reserved.
//

import XCTest
import JsonSerialize

class TestSubStruct: ToJson, FromJson {
    let foo = "bar"

    init(foo: String) {
        self.foo = foo
    }

    func toJson() -> Json {
        return Json.Object(["foo": foo.toJson()])
    }

    class func fromJson(json: Json) -> TestSubStruct? {
        let decoder = JsonDecoder(json: json)
        if let value: String = decoder.readValue("foo") {
            return TestSubStruct(foo: value)
        }
        return nil
    }
}

class TestStruct: ToJson, FromJson {
    let int    = 123
    let float  = 123.0
    let string = "foo"
    let bool   = true
    let array  = ["foo"]
    var dict   = ["foo": "bar"]
    var sub    = TestSubStruct(foo: "bar")
    var date   = NSDate(timeIntervalSince1970: 0)

    init() {}
    init(json: Json) {
        let decoder = JsonDecoder(json: json)
        int    = decoder.readValue("int")!
        float  = decoder.readValue("float")!
        string = decoder.readValue("string")!
        bool   = decoder.readValue("bool")!
        array  = decoder.readArray("array")!
        dict   = decoder.readDictionary("dict")!
        sub    = decoder.readValue("sub")!
        date   = decoder.readValue("date")!
    }

    func toJson() -> Json {
        let json = [
            "int":    int.toJson(),
            "float":  float.toJson(),
            "string": string.toJson(),
            "bool":   bool.toJson(),
            "array":  Json.fromArray(array),
            "dict":   Json.fromDictionary(dict),
            "sub":    sub.toJson(),
            "null":   Json.Null,
            "date":   date.toJson()
        ]
        return Json.Object(json)
    }

    class func fromJson(value: Json) -> TestStruct? {
        return value.object ? TestStruct(json: value) : nil
    }
}

class JsonSerializeTests: XCTestCase {

    func testJsonEncode() {
        let testObject = TestStruct()
        let expected = "{\"int\":123.0,\"bool\":true,\"null\":null,\"date\":0.0," +
                       "\"array\":[\"foo\"],\"dict\":{\"foo\":\"bar\"}," +
                       "\"float\":123.0,\"string\":\"foo\",\"sub\":{\"foo\":\"bar\"}}"
        let encoded = testObject.toJson().toString()
        XCTAssert(encoded == expected, "Invalid JSON: \(encoded)")
    }

    func testJsonEncodeOptional() {
        var test: Int?
        XCTAssert(Json.fromOptional(test).toString() == "null", "Should be Null")

        test = 10
        XCTAssert(Json.fromOptional(test).toString() == "10.0", "Should be 10.0")
    }

    func testJsonDecode() {
        let jsonString = "{\"int\":321.0,\"bool\":false,\"date\":0," +
                         "\"array\":[\"bar\"],\"dict\":{\"bar\":\"baz\"}," +
                         "\"float\":321.0,\"string\":\"bar\",\"sub\":{\"foo\":\"bar\"}}"

        let json = Json.jsonWithJsonString(jsonString)
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
