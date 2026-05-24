import Foundation

public struct Car {
    public let carManufacturer: String
    public let model: String
    public let wikipediaLink: URL?
    public let prices: [Price]
    public let dealers: [Dealer]
}

public enum Currency: Equatable {
    case dollar
    case euro
    case unknown
}

public struct Price {
    public let value: Double
    public let currency: Currency
    public let priceTimeStamp: Date?
}

public struct Address: Equatable {
    public let city: String
    public let street: String
    public let country: String
}

public struct Dealer {
    public let name: String
    public let address: Address
}
