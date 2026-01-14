import SwiftUI

struct InventoryItemRow: View {
    let item: InventoryItem

    var body: some View {
        let title = InventoryItemDisplay.title(for: item)
        let service = InventoryService()
        let low = service.isLowStock(item)
        let unitsRemaining = service.unitsRemaining(for: item)
        let unitsText = unitsRemaining.map {
            Text($0, format: .number.precision(.fractionLength(2)))
        }
        let label = inventoryAccessibilityLabel(
            title: title,
            unitsRemaining: unitsRemaining,
            isLow: low
        )

        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if let secondary = InventoryItemDisplay.secondaryLine(for: item) {
                    Text(secondary)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if let unitsText {
                    HStack(spacing: 4) {
                        unitsText
                        Text("units")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Set unit size")
                        .foregroundStyle(.secondary)
                }
                if low {
                    Text("Low")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }

    private func inventoryAccessibilityLabel(
        title: String,
        unitsRemaining: Double?,
        isLow: Bool
    ) -> String {
        if let unitsRemaining {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            let rounded = formatter.string(from: NSNumber(value: unitsRemaining)) ?? "\(unitsRemaining)"
            let low = isLow ? "low stock, " : ""
            return "\(title), \(low)\(rounded) units remaining"
        }
        return "\(title), unit size not set"
    }
}
