import Foundation
import SwiftData

@Model
final class RateDataModel {
    var sign: String
    var title: String
    var rate: Double
    var timestamp: Date

    init(sign: String, title: String, rate: Double, timestamp: Date) {
        self.sign = sign
        self.title = title
        self.rate = rate
        self.timestamp = timestamp
    }
}
