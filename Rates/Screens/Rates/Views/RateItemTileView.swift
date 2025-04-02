import SwiftUI

struct RateItemTileView: View {
    let item: RateItem
    var body: some View {
        HStack(spacing: 16) {
            CurrencyView(
                sign: item.sign,
                title: item.title,
                subtitle: item.subtitle
            )
            Spacer()
            VStack(alignment: .trailing) {
                Text(item.formattedRate())
                    .font(.headline)
                    .fontWeight(.bold)                
            }
        }
    }
}

#Preview {
    List {
        RateItemTileView(item: .preview)
    }
}
