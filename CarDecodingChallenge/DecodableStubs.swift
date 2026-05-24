import Foundation

public struct NotImplementedError: Error {}

extension Car: Decodable {
    
    /*
     public let carManufacturer: String
     public let model: String
     public let wikipediaLink: URL?
     public let prices: [Price]
     public let dealers: [Dealer]
     
     */
    
    
    
    enum CodingKeys: String, CodingKey {
        case carManufacturer = "car_manufacturer"
        case model = "car_model"
        case wikipediaLink = "wikipedia_link"
        case prices = "price"
        case dealers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        carManufacturer = try container.decode(String.self, forKey: .carManufacturer)
        model = try container.decode(String.self, forKey: .model)
        wikipediaLink = try container.decodeIfPresent(URL.self, forKey: .wikipediaLink)
        prices = try container.decodeIfPresent([Price].self, forKey: .prices) ?? []
        dealers = try container.decodeIfPresent([Dealer].self, forKey: .dealers) ?? []
    }
}

extension Currency: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "USD":
            self = .dollar
        case "EUR":
            self = .euro
        default:
            self = .unknown
        }
    }
}

extension Price: Decodable {
    
    /*
     - Decode `Price` from a JSON object.
     - `value` is required and must decode to `Double`.
     - `currency` is required and must decode to `Currency`.
     - Missing or `null` `value`/`currency` must fail decoding.
     - `price_time_stamp` maps to `priceTimeStamp`.
     - `priceTimeStamp` may be missing or `null`; decode those cases as `nil`.
     - For non-null timestamps, use `DateFormatter` with locale `en_US_POSIX`, time zone `TimeZone(secondsFromGMT: 0)`, and the format implied by the examples: `yyyy-MM-dd'T'HH:mm:ss`.
     
     */

    enum CodingKeys: String, CodingKey {
        case value
        case currency
        case priceTimeStamp = "price_time_stamp"
    }
    
    public init(from decoder: Decoder) throws {
        
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        value = try container.decode(Double.self, forKey: .value)
        currency = try container.decode(Currency.self, forKey: .currency)
        let priceTimeStampString = try container.decodeIfPresent(String.self, forKey: .priceTimeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let priceTimeStampString {
            priceTimeStamp =  dateFormatter.date(from: priceTimeStampString)
        } else {
            priceTimeStamp = nil
        }
    }
}

extension Address: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case city
        case street
        case country
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        city = try container.decode(String.self, forKey: .city)
        street = try container.decode(String.self, forKey: .street)
        country = try container.decode(String.self, forKey: .country)
    }
}

extension Dealer: Decodable {
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case city
        case street
        case country
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        let city = try container.decode(String.self, forKey: .city)
        let street = try container.decode(String.self, forKey: .street)
        let country = try container.decode(String.self, forKey: .country)
        
        address = Address(city: city, street: street, country: country)
    }
}
