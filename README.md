# CarDecodingChallenge

This Xcode project is a test harness for the Swift `Decodable` car task shown in the screenshots. Production code intentionally contains only the model definitions and `Decodable` stubs that throw `NotImplementedError`.

Implement the challenge in:

```text
CarDecodingChallenge/DecodableStubs.swift
```

## Implementation Contract

Treat this section like the written problem statement and the tests as executable acceptance criteria.

### Car

- Decode a `Car` from a JSON object.
- Map `car_manufacturer` to `carManufacturer`.
- Map `car_model` to `model`.
- Map `wikipedia_link` to `wikipediaLink`.
- Map the JSON key `price` to the Swift property `prices`.
- Decode `dealers` from the `dealers` JSON key.
- `carManufacturer` and `model` are required. Missing or `null` values must fail decoding.
- `wikipediaLink` is optional. Missing or `null` values should decode as `nil`.
- `prices` and `dealers` may be empty, missing, or `null`; decode those cases as empty arrays.
- Do not use `try container.decode([T].self, forKey:) ?? []` for missing arrays. `decode(_:forKey:)` throws before `?? []` can run. Use `decodeIfPresent`, `contains`, or equivalent safe handling.

### Currency

- Decode `Currency` from a single JSON string.
- `"USD"` decodes to `.dollar`.
- `"EUR"` decodes to `.euro`.
- Any other non-null string, including lowercase values and unsupported currencies like `"CHF"`, decodes to `.unknown`.
- `null` must fail decoding.

### Price

- Decode `Price` from a JSON object.
- `value` is required and must decode to `Double`.
- `currency` is required and must decode to `Currency`.
- Missing or `null` `value`/`currency` must fail decoding.
- `price_time_stamp` maps to `priceTimeStamp`.
- `priceTimeStamp` may be missing or `null`; decode those cases as `nil`.
- For non-null timestamps, use `DateFormatter` with locale `en_US_POSIX`, time zone `TimeZone(secondsFromGMT: 0)`, and the format implied by the examples: `yyyy-MM-dd'T'HH:mm:ss`.

### Address

- Decode `Address` from flat JSON fields.
- `city`, `street`, and `country` are required.
- Missing or `null` `city`/`street`/`country` must fail decoding.

### Dealer

- Decode `Dealer` from a JSON object whose address fields are flat, not nested.
- `name`, `city`, `street`, and `country` are required.
- Use `city`, `street`, and `country` to create the dealer's `Address`.
- Missing or `null` required fields must fail decoding.

## Test Coverage

The suite covers complete JSON, missing/empty/null arrays, required key failures, optional URL behavior, direct `Currency`, `Price`, `Address`, and `Dealer` decoding, timestamp formatting, unsupported currencies, and flat dealer-address decoding.

Run:

```sh
xcodebuild test -scheme CarDecodingChallenge -destination 'platform=iOS Simulator,name=iPhone 17'
```
# decoding-swift
