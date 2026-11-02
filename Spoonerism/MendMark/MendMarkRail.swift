import SwiftUI

/// Compact progress summary. The full history stays in Collection.
struct MendMarkRail: View {
    @Bindable var desk: OnsetDesk
    var columnWidth: CGFloat

    var body: some View {
        Button { desk.present(.saved) } label: {
            HStack(spacing: 0) {
                statistic("Solved", count: desk.onset.mendedWorks.count, symbol: "checkmark.circle")
                Divider().frame(height: 32)
                statistic("Hits", count: desk.onset.reviewableMends.count, symbol: "scope")
                Divider().frame(height: 32)
                statistic("Misses", count: desk.onset.reviewableMuffs.count, symbol: "arrow.counterclockwise")
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .marrowFlat()
        }
        .buttonStyle(MarrowRowStyle())
        .accessibilityLabel("Collection, \(desk.onset.mendedWorks.count) solved, \(desk.onset.reviewableMends.count) hits, \(desk.onset.reviewableMuffs.count) misses")
    }

    private func statistic(_ title: String, count: Int, symbol: String) -> some View {
        VStack(spacing: 6) {
            Text(MarrowFigures.whole(count))
                .font(.system(.title2, design: .serif).weight(.medium).monospacedDigit())
                .foregroundStyle(MarrowInk.ink)
            Text(title).font(.caption).foregroundStyle(MarrowInk.muted)
        }
        .frame(maxWidth: .infinity)
    }
}
