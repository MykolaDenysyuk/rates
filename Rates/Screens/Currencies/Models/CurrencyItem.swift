struct CurrencyItem: Identifiable {
    var id: Int { sign.hashValue }

    let sign: String
    let title: String
    let subtitle: String
    let isSelected: Bool
}


extension CurrencyItem {
    func toggled() -> CurrencyItem {
        CurrencyItem(
            sign: sign,
            title: title,
            subtitle: subtitle,
            isSelected: !isSelected
        )
    }
}
