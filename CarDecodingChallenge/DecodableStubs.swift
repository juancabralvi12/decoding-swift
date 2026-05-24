import Foundation

public struct NotImplementedError: Error {}

extension Car: Decodable {
    
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
