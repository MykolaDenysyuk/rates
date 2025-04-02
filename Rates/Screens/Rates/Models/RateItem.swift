import Foundation

struct RateItem: Hashable, Identifiable {
    var id: Int { sign.hashValue }
    let updated: Date
    let sign: String
    let title: String
    let subtitle: String
    let rate: Double
    let delta: Double

    func hash(into hasher: inout Hasher) {
        hasher.combine(sign)
    }

    func formattedRate() -> String {
        let numericFormatter = NumberFormatter()
        numericFormatter.numberStyle = .currency
        numericFormatter.currencyCode = "USD"
        numericFormatter.minimumFractionDigits = 2
        numericFormatter.maximumFractionDigits = 4
        return numericFormatter.string(from: NSNumber(value: 1/rate)) ?? ""
    }
}

extension RateItem {
    static let preview = RateItem(
        updated: Date(),
        sign: "$",
        title: "USD",
        subtitle: "US Dollar",
        rate: 1,
        delta: 0
    )
}
