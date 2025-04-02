import SwiftUI

struct CurrencyView: View {
    let sign: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Text(Currency.symbol(forCurrencyCode: sign))
                .frame(width: 36, height: 36)
                .font(.title)
                .minimumScaleFactor(0.5)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.mint))
                .shadow(radius: 5)
            VStack(alignment: .leading) {
                Text(title.uppercased())
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    List {
        CurrencyView(sign: "$", title: "USD", subtitle: "US Dollar")
    }
}
