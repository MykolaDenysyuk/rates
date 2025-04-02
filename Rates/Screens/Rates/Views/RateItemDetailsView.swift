import SwiftUI

struct RateItemDetailsView: View {
    let item: RateItem
    var body: some View {
        Text("Item at \(item.updated, format: Date.FormatStyle(date: .numeric, time: .standard))")
    }
}

#Preview {
    RateItemDetailsView(item: .preview)
}

