import Foundation

extension Car: Decodable {
    private enum CodingKeys: String, CodingKey {
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
    private enum CodingKeys: String, CodingKey {
        case value
        case currency
        case priceTimeStamp = "price_time_stamp"
    }

    private static let priceTimeStampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        value = try container.decode(Double.self, forKey: .value)
        currency = try container.decode(Currency.self, forKey: .currency)

        guard let priceTimeStampString = try container.decodeIfPresent(String.self, forKey: .priceTimeStamp) else {
            priceTimeStamp = nil
            return
        }

        guard let date = Self.priceTimeStampFormatter.date(from: priceTimeStampString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .priceTimeStamp,
                in: container,
                debugDescription: "Expected date format yyyy-MM-dd'T'HH:mm:ss"
            )
        }

        priceTimeStamp = date
    }
}

extension Address: Decodable {
    private enum CodingKeys: String, CodingKey {
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
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try Address(from: decoder)
    }
}
