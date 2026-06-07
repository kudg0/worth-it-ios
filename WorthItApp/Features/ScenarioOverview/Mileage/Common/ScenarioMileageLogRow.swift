import SwiftUI

struct ScenarioMileageLogRow: View {
    let item: ScenarioOverviewView.MileageLogItem
    let onEditMileage: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            header
            footer
        }
        .padding(WorthItSpacing.xl)
        .background(Color(hex: 0x171B28), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
        .onTapGesture {
            onEditMileage(item.id)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.l) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 40, height: 40)
                .background(accentColor.opacity(item.kind == .trip ? 0.10 : 0.14), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(item.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: WorthItSpacing.m)

            Button {
                onEditMileage(item.id)
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }

    private var footer: some View {
        HStack(alignment: .bottom) {
            value
            Spacer(minLength: WorthItSpacing.m)

            VStack(alignment: .trailing, spacing: 1) {
                Text(Self.dateFormatter.string(from: item.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                    .textCase(.uppercase)

                Text(Self.timeFormatter.string(from: item.date))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.40))
            }
        }
    }

    @ViewBuilder
    private var value: some View {
        switch item.kind {
        case .odometer:
            HStack(spacing: WorthItSpacing.s) {
                Text(item.previousOdometer.map(Self.formatInt) ?? "-")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)

                Image(systemName: "arrow.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)

                Text(item.currentOdometer.map { "\(Self.formatInt($0)) \(item.unit)" } ?? "-")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
            }
        case .trip:
            Text("+\(Self.formatDouble(item.distance ?? 0, fractionDigits: 1)) \(item.unit)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.accentGold)
        }
    }

    private var iconName: String {
        switch item.kind {
        case .odometer:
            "speedometer"
        case .trip:
            "point.topleft.down.curvedto.point.bottomright.up"
        }
    }

    private var accentColor: Color {
        switch item.kind {
        case .odometer:
            WorthItColor.primaryContainer
        case .trip:
            WorthItColor.accentGold
        }
    }

    static func formatInt(_ value: Int) -> String {
        intFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static func formatDouble(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private static let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
