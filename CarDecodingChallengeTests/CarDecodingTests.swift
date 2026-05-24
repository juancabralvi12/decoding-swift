import XCTest
@testable import CarDecodingChallenge

final class CarDecodingTests: XCTestCase {
    func testDecodesCompleteCarJSON() throws {
        let car = try Self.decodeCar(Self.completeCarJSON)

        XCTAssertEqual(car.carManufacturer, "Mercedes")
        XCTAssertEqual(car.model, "W212")
        XCTAssertEqual(car.wikipediaLink, URL(string: "https://cars.mercedes.com"))

        XCTAssertEqual(car.prices.count, 1)
        XCTAssertEqual(car.prices[0].value, 500_000)
        XCTAssertEqual(car.prices[0].currency, CarDecodingChallenge.Currency.dollar)
        XCTAssertEqual(car.prices[0].priceTimeStamp, Self.date("2020-06-20T01:40:00"))

        XCTAssertEqual(car.dealers.count, 2)
        XCTAssertEqual(car.dealers[0].name, "France-Car-Dealer")
        XCTAssertEqual(car.dealers[0].address, Address(city: "Paris", street: "Street 3", country: "France"))
        XCTAssertEqual(car.dealers[1].name, "Poland-Car-Dealer")
        XCTAssertEqual(car.dealers[1].address, Address(city: "Warsaw", street: "Warszawska 3", country: "Poland"))
    }

    func testMissingDealersKeyDecodesAsEmptyArray() throws {
        let car = try Self.decodeCar(Self.carWithoutDealersJSON)

        XCTAssertEqual(car.carManufacturer, "Honda")
        XCTAssertEqual(car.model, "CR-V")
        XCTAssertEqual(car.dealers.count, 0)
        XCTAssertEqual(car.prices.count, 2)
        XCTAssertEqual(car.prices[0].currency, CarDecodingChallenge.Currency.unknown)
        XCTAssertEqual(car.prices[0].priceTimeStamp, Self.date("2020-12-25T12:40:00"))
        XCTAssertEqual(car.prices[1].currency, CarDecodingChallenge.Currency.euro)
        XCTAssertEqual(car.prices[1].priceTimeStamp, Self.date("2020-01-10T12:40:00"))
    }

    func testMissingPricesKeyDecodesAsEmptyArray() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Honda",
          "car_model": "CR-V",
          "wikipedia_link": "https://wikipedia.com/honda",
          "dealers": []
        }
        """)

        XCTAssertEqual(car.prices.count, 0)
        XCTAssertEqual(car.dealers.count, 0)
    }

    func testMissingPricesAndDealersKeysDecodeAsEmptyArrays() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Honda",
          "car_model": "CR-V"
        }
        """)

        XCTAssertEqual(car.prices.count, 0)
        XCTAssertEqual(car.dealers.count, 0)
        XCTAssertNil(car.wikipediaLink)
    }

    func testEmptyPricesAndDealersArraysRemainEmpty() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [],
          "dealers": []
        }
        """)

        XCTAssertTrue(car.prices.isEmpty)
        XCTAssertTrue(car.dealers.isEmpty)
    }

    func testMissingRequiredCarManufacturerFailsDecoding() {
        assertCarDecodingFails("""
        {
          "car_model": "W212",
          "price": [],
          "dealers": []
        }
        """)
    }

    func testNullRequiredCarManufacturerFailsDecoding() {
        assertCarDecodingFails("""
        {
          "car_manufacturer": null,
          "car_model": "W212",
          "price": [],
          "dealers": []
        }
        """)
    }

    func testMissingRequiredCarModelFailsDecoding() {
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "price": [],
          "dealers": []
        }
        """)
    }

    func testNullRequiredCarModelFailsDecoding() {
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": null,
          "price": [],
          "dealers": []
        }
        """)
    }

    func testWikipediaLinkIsOptionalWhenMissingOrNull() throws {
        let missing = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [],
          "dealers": []
        }
        """)
        let null = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "wikipedia_link": null,
          "price": [],
          "dealers": []
        }
        """)

        XCTAssertNil(missing.wikipediaLink)
        XCTAssertNil(null.wikipediaLink)
    }

    func testNullPricesAndDealersDecodeAsEmptyArrays() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": null,
          "dealers": null
        }
        """)

        XCTAssertTrue(car.prices.isEmpty)
        XCTAssertTrue(car.dealers.isEmpty)
    }

    func testCurrencyMapsUSDAndEURAndTreatsUnsupportedValuesAsUnknown() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [
            { "value": 1, "currency": "USD" },
            { "value": 2, "currency": "EUR" },
            { "value": 3, "currency": "CHF" }
          ],
          "dealers": []
        }
        """)

        XCTAssertEqual(
            car.prices.map(\.currency),
            [
                CarDecodingChallenge.Currency.dollar,
                CarDecodingChallenge.Currency.euro,
                CarDecodingChallenge.Currency.unknown
            ]
        )
    }

    func testCurrencyDecodesDirectlyFromSingleStringValues() throws {
        XCTAssertEqual(try Self.decode(Currency.self, #""USD""#), CarDecodingChallenge.Currency.dollar)
        XCTAssertEqual(try Self.decode(Currency.self, #""EUR""#), CarDecodingChallenge.Currency.euro)
        XCTAssertEqual(try Self.decode(Currency.self, #""CHF""#), CarDecodingChallenge.Currency.unknown)
        XCTAssertEqual(try Self.decode(Currency.self, #""usd""#), CarDecodingChallenge.Currency.unknown)
    }

    func testCurrencyFailsWhenNull() {
        assertDecodingFails(Currency.self, "null")
    }

    func testPriceTimeStampMayBeMissingOrNull() throws {
        let car = try Self.decodeCar("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [
            { "value": 1, "currency": "USD" },
            { "value": 2, "currency": "EUR", "price_time_stamp": null }
          ],
          "dealers": []
        }
        """)

        XCTAssertNil(car.prices[0].priceTimeStamp)
        XCTAssertNil(car.prices[1].priceTimeStamp)
    }

    func testPriceDecodesDirectlyWithDecimalValueAndTimestamp() throws {
        let price = try Self.decode(Price.self, """
        {
          "value": 12345.67,
          "currency": "EUR",
          "price_time_stamp": "2020-01-10T12:40:00"
        }
        """)

        XCTAssertEqual(price.value, 12_345.67, accuracy: 0.0001)
        XCTAssertEqual(price.currency, CarDecodingChallenge.Currency.euro)
        XCTAssertEqual(price.priceTimeStamp, Self.date("2020-01-10T12:40:00"))
    }

    func testPriceDecodesDirectlyWhenTimestampIsMissingOrNull() throws {
        let missing = try Self.decode(Price.self, """
        {
          "value": 1,
          "currency": "USD"
        }
        """)
        let null = try Self.decode(Price.self, """
        {
          "value": 1,
          "currency": "USD",
          "price_time_stamp": null
        }
        """)

        XCTAssertNil(missing.priceTimeStamp)
        XCTAssertNil(null.priceTimeStamp)
    }

    func testPriceFailsWhenValueIsMissingOrNull() {
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [{ "currency": "USD" }],
          "dealers": []
        }
        """)
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [{ "value": null, "currency": "USD" }],
          "dealers": []
        }
        """)
    }

    func testPriceFailsWhenCurrencyIsMissingOrNull() {
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [{ "value": 1 }],
          "dealers": []
        }
        """)
        assertCarDecodingFails("""
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [{ "value": 1, "currency": null }],
          "dealers": []
        }
        """)
    }

    func testPriceDirectDecodeFailsWhenRequiredValuesAreMissingOrNull() {
        assertDecodingFails(Price.self, """
        { "currency": "USD" }
        """)
        assertDecodingFails(Price.self, """
        { "value": null, "currency": "USD" }
        """)
        assertDecodingFails(Price.self, """
        { "value": 1 }
        """)
        assertDecodingFails(Price.self, """
        { "value": 1, "currency": null }
        """)
    }

    func testAddressFailsWhenAnyPropertyIsMissingOrNull() {
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "street": "Street 3", "country": "France" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "city": "Paris", "street": null, "country": "France" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "city": "Paris", "street": "Street 3" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "city": null, "street": "Street 3", "country": "France" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "city": "Paris", "country": "France" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": "France-Car-Dealer", "city": "Paris", "street": "Street 3", "country": null }
        """))
    }

    func testAddressDecodesDirectlyAndFailsWhenAnyPropertyIsMissingOrNull() throws {
        let address = try Self.decode(Address.self, """
        {
          "city": "Paris",
          "street": "Street 3",
          "country": "France"
        }
        """)

        XCTAssertEqual(address, Address(city: "Paris", street: "Street 3", country: "France"))
        assertDecodingFails(Address.self, """
        { "street": "Street 3", "country": "France" }
        """)
        assertDecodingFails(Address.self, """
        { "city": "Paris", "street": null, "country": "France" }
        """)
        assertDecodingFails(Address.self, """
        { "city": "Paris", "street": "Street 3" }
        """)
    }

    func testDealerFailsWhenNameIsMissingOrNull() {
        assertCarDecodingFails(Self.carWithDealer("""
        { "city": "Paris", "street": "Street 3", "country": "France" }
        """))
        assertCarDecodingFails(Self.carWithDealer("""
        { "name": null, "city": "Paris", "street": "Street 3", "country": "France" }
        """))
    }

    func testDealerDecodesFlatAddressFieldsIntoAddress() throws {
        let dealer = try Self.decode(Dealer.self, """
        {
          "name": "France-Car-Dealer",
          "city": "Paris",
          "street": "Street 3",
          "country": "France"
        }
        """)

        XCTAssertEqual(dealer.name, "France-Car-Dealer")
        XCTAssertEqual(dealer.address, Address(city: "Paris", street: "Street 3", country: "France"))
    }

    func testDealerDirectDecodeFailsWhenNameOrAddressFieldsAreMissingOrNull() {
        assertDecodingFails(Dealer.self, """
        { "city": "Paris", "street": "Street 3", "country": "France" }
        """)
        assertDecodingFails(Dealer.self, """
        { "name": null, "city": "Paris", "street": "Street 3", "country": "France" }
        """)
        assertDecodingFails(Dealer.self, """
        { "name": "France-Car-Dealer", "street": "Street 3", "country": "France" }
        """)
        assertDecodingFails(Dealer.self, """
        { "name": "France-Car-Dealer", "city": "Paris", "street": "Street 3", "country": null }
        """)
    }
}

private extension CarDecodingTests {
    static let completeCarJSON = """
    {
      "car_manufacturer": "Mercedes",
      "car_model": "W212",
      "wikipedia_link": "https://cars.mercedes.com",
      "price": [
        {
          "value": 500000,
          "currency": "USD",
          "price_time_stamp": "2020-06-20T01:40:00"
        }
      ],
      "dealers": [
        {
          "name": "France-Car-Dealer",
          "country": "France",
          "street": "Street 3",
          "city": "Paris"
        },
        {
          "name": "Poland-Car-Dealer",
          "country": "Poland",
          "street": "Warszawska 3",
          "city": "Warsaw"
        }
      ]
    }
    """

    static let carWithoutDealersJSON = """
    {
      "car_manufacturer": "Honda",
      "car_model": "CR-V",
      "wikipedia_link": "https://wikipedia.com/honda",
      "price": [
        {
          "value": 20000,
          "currency": "CHF",
          "price_time_stamp": "2020-12-25T12:40:00"
        },
        {
          "value": 12500,
          "currency": "EUR",
          "price_time_stamp": "2020-01-10T12:40:00"
        }
      ]
    }
    """

    static func decodeCar(_ json: String, file: StaticString = #filePath, line: UInt = #line) throws -> Car {
        try decode(Car.self, json, file: file, line: line)
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        _ json: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> T {
        do {
            let data = Data(json.utf8)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            XCTFail("Expected \(T.self) to decode, but got error: \\(error)", file: file, line: line)
            throw error
        }
    }

    static func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: string)!
    }

    static func carWithDealer(_ dealerJSON: String) -> String {
        """
        {
          "car_manufacturer": "Mercedes",
          "car_model": "W212",
          "price": [],
          "dealers": [
            \(dealerJSON)
          ]
        }
        """
    }

    func assertCarDecodingFails(_ json: String, file: StaticString = #filePath, line: UInt = #line) {
        assertDecodingFails(Car.self, json, file: file, line: line)
    }

    func assertDecodingFails<T: Decodable>(
        _ type: T.Type,
        _ json: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try JSONDecoder().decode(T.self, from: Data(json.utf8)), file: file, line: line)
    }
}
