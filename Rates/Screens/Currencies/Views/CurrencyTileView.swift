import SwiftUI

struct CurrencyTileView: View {
    let item: CurrencyItem

    var body: some View {
        HStack(spacing: 16) {
            CurrencyView(
                sign: item.sign,
                title: item.title,
                subtitle: item.subtitle
            )
            Spacer()
            VStack {
                if (item.isSelected) {
                    Image(systemName: "checkmark")
                        .scaledToFit()
                }
                else {
                    Spacer()
                }

            }
            .frame(width: 30, height: 30)
            .fontWeight(.bold)
            .foregroundColor(.mint)
            .background(
                Circle().stroke(.fill, lineWidth: 1)
            )


        }
    }
}

#Preview {
    List {
        CurrencyTileView(
            item: CurrencyItem(
                sign: "USD",
                title: "USD",
                subtitle: "US Dollar",
                isSelected: true
            )
        )
    }
}
