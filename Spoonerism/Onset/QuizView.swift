import SwiftUI

/// The active round stays on screen while the gallery and collection open as sheets.
struct QuizView: View {
    @Bindable var desk: OnsetDesk
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    masthead
                    if desk.quizIsEmpty {
                        FluentView(
                            headline: desk.recoveredNotice ? MarrowCopy.recoverHeadline : "Art with a twist.",
                            line: "Save a painting from the gallery. Then put its words back in order.",
                            actionTitle: "Explore the gallery"
                        ) { desk.present(.explore) }
                        .frame(minHeight: 420)
                    } else {
                        introduction
                        if let fault = desk.onsetFault {
                            Label(fault, systemImage: "exclamationmark.circle")
                                .font(.footnote)
                                .foregroundStyle(MarrowInk.ink)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .marrowFlat()
                            Button("Retry") { Task { await desk.flush() } }
                                .buttonStyle(MarrowPillStyle(tone: .quiet))
                        }
                        if desk.recoveredNotice {
                            Text(MarrowCopy.recoverLine).font(.footnote).foregroundStyle(MarrowInk.muted)
                        }
                        if geometry.size.width >= 700 {
                            HStack(alignment: .top, spacing: 32) {
                                painting(height: min(geometry.size.height * 0.55, 480))
                                    .frame(maxWidth: .infinity)
                                roundPanel
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                            painting(height: min(max(geometry.size.height * 0.27, 140), 300))
                            roundPanel
                        }
                        MendMarkRail(desk: desk, columnWidth: min(geometry.size.width - 40, 1000))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 1040)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(MarrowInk.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { navigation }
        .sensoryFeedback(.impact(weight: .medium), trigger: desk.mendPulse)
        .animation(MarrowMotion.snap(reduceMotion), value: desk.onset.sign)
        .sheet(item: compactCover) { coverView($0) }
        .fullScreenCover(item: regularCover) { coverView($0) }
    }

    private var masthead: some View {
        HStack(spacing: 12) {
            Image(systemName: "textformat.abc")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(MarrowInk.surface)
                .frame(width: 42, height: 42)
                .background(MarrowInk.accent, in: RoundedRectangle(cornerRadius: 13))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Spoonerism").font(.system(.headline, design: .serif))
                Text("THE ART OF WORDPLAY")
                    .font(.caption2.weight(.semibold)).tracking(1.2)
                    .foregroundStyle(MarrowInk.muted)
            }
            Spacer(minLength: 0)
            Button { desk.present(.spoonMend) } label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(MarrowGlyphStyle())
            .accessibilityLabel("How it works")
        }
        .foregroundStyle(MarrowInk.ink)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(MarrowInk.accent).frame(width: 6, height: 6)
                Text(desk.onset.sign == .mended ? "ROUND COMPLETE" : "YOUR DAILY WORDPLAY")
                    .font(.system(.caption2).weight(.semibold)).tracking(1.5)
                    .foregroundStyle(MarrowInk.accent)
            }
            Text(MarrowCopy.verb(sign: desk.onset.sign))
                .font(.system(.largeTitle, design: .serif).weight(.medium))
                .foregroundStyle(MarrowInk.ink)
                .accessibilityAddTraits(.isHeader)
            Text(MarrowCopy.nextTap(sign: desk.onset.sign))
                .font(.subheadline)
                .foregroundStyle(MarrowInk.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func painting(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            QuizTile(work: desk.displayedWork, showSuccess: desk.showSuccess)
                .frame(height: height)
                .clipped()
            VStack(alignment: .leading, spacing: 5) {
                Text(desk.displayedWork?.title ?? "Painting")
                    .font(.system(.title3, design: .serif).weight(.medium))
                    .foregroundStyle(MarrowInk.ink)
                Text([desk.displayedWork?.artist, desk.displayedWork?.dated].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(MarrowInk.muted)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarrowInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(MarrowInk.ink.opacity(0.06)))
    }

    private var roundPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            LineView(desk: desk)
            HStack(spacing: 12) {
                Label(desk.onset.sign == .mended ? "Beautifully untangled." : "Tap a word to test its first letter.",
                      systemImage: desk.onset.sign == .mended ? "checkmark.circle.fill" : "hand.tap")
                    .font(.caption)
                    .foregroundStyle(MarrowInk.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button { Task { await desk.undoNewest() } } label: {
                    Image(systemName: "arrow.uturn.backward").frame(width: 44, height: 44)
                }
                .buttonStyle(MarrowGlyphStyle())
                .foregroundStyle(MarrowInk.ink)
                .disabled(!desk.undoEnabled)
                .accessibilityLabel("Undo")
                .accessibilityHint(MarrowCopy.undoHint)
            }
            if desk.onset.sign != .spooned {
                Button { Task { await desk.spoonWork() } } label: {
                    Label("Next painting", systemImage: "arrow.right")
                }
                .buttonStyle(MarrowPillStyle(isLoading: desk.spoonBusy))
                .disabled(!desk.spoonEnabled)
            }
        }
    }

    private var navigation: some View {
        HStack(spacing: 0) {
            navigationItem("Play", symbol: "rectangle.on.rectangle", selected: true) { }
            navigationItem("Gallery", symbol: "square.grid.2x2") { desk.present(.explore) }
            navigationItem("Collection", symbol: "bookmark") { desk.present(.saved) }
            navigationItem("Settings", symbol: "slider.horizontal.3") { desk.present(.settings) }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(MarrowInk.surface.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Rectangle().fill(MarrowInk.ink.opacity(0.08)).frame(height: 1) }
    }

    private func navigationItem(_ title: String, symbol: String, selected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 19, weight: selected ? .semibold : .regular))
                Text(title).font(.caption2.weight(selected ? .semibold : .medium))
            }
            .foregroundStyle(selected ? MarrowInk.accent : MarrowInk.muted)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder
    private func coverView(_ cover: MarrowCover) -> some View {
        switch cover {
        case .explore: ExploreView(desk: desk)
        case .saved: SavedView(desk: desk)
        case .settings: SettingsView(desk: desk)
        case .spoonMend: SpoonMendSheet(desk: desk)
        }
    }

    private var compactCover: Binding<MarrowCover?> {
        Binding(get: { sizeClass == .regular ? nil : desk.cover }, set: { desk.cover = $0 })
    }

    private var regularCover: Binding<MarrowCover?> {
        Binding(get: { sizeClass == .regular ? desk.cover : nil }, set: { desk.cover = $0 })
    }
}
