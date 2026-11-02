import SwiftUI

/// Role: Work. Saved screen of filed works plus hits listed together with misses. Collecting without a test is the crate clone. Arrives as a sheet over Quiz.
struct SavedView: View {
    @Bindable var desk: OnsetDesk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        MarrowSheetHost {
            NavigationStack {
                Group {
                    if desk.savedIsEmpty, desk.onsetFault != nil {
                        ShelfQuiet(
                            art: MarrowArt.emptyList,
                            headline: "Kept paintings could not load.",
                            line: desk.onsetFault ?? MarrowCopy.writeFailed,
                            actionTitle: "Close"
                        ) {
                            dismiss()
                        }
                    } else if desk.savedIsEmpty {
                        emptyPage
                    } else {
                        populated
                    }
                }
                .background(MarrowInk.background.ignoresSafeArea())
                .navigationTitle("Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(MarrowType.font(.headline, size: typeSize))
                                .foregroundStyle(MarrowInk.ink)
                                .frame(minWidth: MarrowSpace.hit, minHeight: MarrowSpace.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var emptyPage: some View {
        ShelfQuiet(
            art: MarrowArt.emptyList,
            headline: MarrowCopy.savedEmptyHeadline,
            line: MarrowCopy.savedEmptyLine,
            actionTitle: "Open Quiz"
        ) {
            dismiss()
        }
    }

    private var populated: some View {
        List {
            Section {
                tally
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(MarrowInk.background)
                    .listRowSeparator(.hidden)
            }
            if let fault = desk.onsetFault {
                Section {
                    Text(fault)
                        .font(MarrowType.font(.micro, size: typeSize))
                        .foregroundStyle(MarrowInk.ink)
                        .listRowBackground(MarrowInk.surface)
                    Button("Return to Quiz") {
                        dismiss()
                    }
                    .font(MarrowType.font(.caption, size: typeSize))
                    .foregroundStyle(MarrowInk.ink)
                    .frame(maxWidth: .infinity, minHeight: MarrowSpace.hit, alignment: .leading)
                    .contentShape(Rectangle())
                    .buttonStyle(MarrowRowStyle())
                    .listRowBackground(MarrowInk.surface)
                    .accessibilityHint("Closes kept paintings and returns to the line.")
                }
            }
            if !desk.onset.mendedWorks.isEmpty {
                Section {
                    ForEach(desk.onset.mendedWorks.reversed()) { work in
                        mendedRow(work)
                            .listRowBackground(MarrowInk.surface)
                            .listRowSeparatorTint(MarrowInk.muted.opacity(0.35))
                    }
                } header: {
                    Text(MarrowCopy.filedLabel)
                        .font(MarrowType.font(.caption, size: typeSize))
                        .foregroundStyle(MarrowInk.ink)
                }
            }
            if !mixedMarks.isEmpty {
                Section {
                    ForEach(mixedMarks) { stroke in
                        markRow(stroke)
                            .listRowBackground(MarrowInk.surface)
                            .listRowSeparatorTint(MarrowInk.muted.opacity(0.35))
                    }
                } header: {
                    Text("Hits and misses")
                        .font(MarrowType.font(.caption, size: typeSize))
                        .foregroundStyle(MarrowInk.ink)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, MarrowSpace.outer)
    }

    private var missLine: String {
        let count = MarrowFigures.whole(desk.onset.reviewableMuffs.count)
        return "\(count) misses"
    }

    private var tally: some View {
        HStack(spacing: 12) {
            collectionStat("Solved", count: desk.onset.mendedWorks.count)
            collectionStat("Hits", count: desk.onset.reviewableMends.count)
            collectionStat("Misses", count: desk.onset.reviewableMuffs.count)
        }
        .padding(.vertical, 16)
    }

    private func collectionStat(_ title: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(MarrowFigures.whole(count))
                .font(.system(.largeTitle, design: .serif).monospacedDigit())
                .foregroundStyle(MarrowInk.ink)
            Text(title).font(.caption).foregroundStyle(MarrowInk.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .marrowFlat()
    }

    private func mendedRow(_ work: Work) -> some View {
        HStack(alignment: .center, spacing: MarrowSpace.gap) {
            MarrowThumb(url: work.imageURL, side: MarrowSpace.step(7), objectID: work.objectID)
            VStack(alignment: .leading, spacing: MarrowSpace.inner) {
                Text(work.title)
                    .font(MarrowType.font(.body, size: typeSize))
                    .foregroundStyle(MarrowInk.ink)
                    .lineLimit(2)
                Text(work.artist)
                    .font(MarrowType.font(.caption, size: typeSize))
                    .foregroundStyle(MarrowInk.muted)
                    .lineLimit(2)
                Text(MarrowFigures.daykey(work.daykey))
                    .font(.caption2).foregroundStyle(MarrowInk.muted)
            }
            Spacer(minLength: MarrowSpace.gap)
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(MarrowInk.accent)
        }
        .padding(.vertical, MarrowSpace.inner)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(work.title), \(work.artist), filed")
    }

    private func markRow(_ stroke: SavedStroke) -> some View {
        HStack(alignment: .center, spacing: MarrowSpace.gap) {
            Image(systemName: stroke.isMend ? "checkmark.circle" : "xmark.circle")
                .font(MarrowType.font(.headline, size: typeSize))
                .foregroundStyle(MarrowInk.ink)
                .frame(width: MarrowSpace.hit, height: MarrowSpace.hit)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: MarrowSpace.inner) {
                Text(stroke.headline)
                    .font(MarrowType.font(.body, size: typeSize))
                    .foregroundStyle(MarrowInk.ink)
                    .lineLimit(1)
                Text(stroke.detail(work: desk.work(for: stroke.workID)))
                    .font(MarrowType.font(.caption, size: typeSize))
                    .foregroundStyle(MarrowInk.muted)
                    .lineLimit(2)
            }
            Spacer(minLength: MarrowSpace.gap)

        }
        .padding(.vertical, MarrowSpace.inner)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stroke.voice(work: desk.work(for: stroke.workID)))
    }

    private var mixedMarks: [SavedStroke] {
        let mends = desk.onset.reviewableMends.map(SavedStroke.mend)
        let muffs = desk.onset.reviewableMuffs.map(SavedStroke.muff)
        return (mends + muffs).sorted { lhs, rhs in
            if lhs.daykey != rhs.daykey { return lhs.daykey > rhs.daykey }
            return lhs.id.uuidString > rhs.id.uuidString
        }
    }
}

/// Role: Work. Same Saved screen. Named for the live driver key saved.
struct Saved: View {
    @Bindable var desk: OnsetDesk

    var body: some View {
        SavedView(desk: desk)
    }
}

/// Role: Work. One Saved row that can be a MendMark or a MuffMark. Listed together.
enum SavedStroke: Identifiable, Equatable {
    case mend(MendMark)
    case muff(MuffMark)

    var id: UUID {
        switch self {
        case .mend(let mark): mark.id
        case .muff(let mark): mark.id
        }
    }

    var workID: UUID {
        switch self {
        case .mend(let mark): mark.workID
        case .muff(let mark): mark.workID
        }
    }

    var daykey: Int {
        switch self {
        case .mend(let mark): mark.daykey
        case .muff(let mark): mark.daykey
        }
    }

    var isMend: Bool {
        if case .mend = self { return true }
        return false
    }

    var headline: String {
        switch self {
        case .mend(let mark):
            return "Hit \(mark.opening)"
        case .muff(let mark):
            return "Miss \(mark.spoken)"
        }
    }

    func detail(work: Work?) -> String {
        work?.title ?? "Work"
    }

    func voice(work: Work?) -> String {
        let title = work?.title ?? "Work"
        switch self {
        case .mend(let mark):
            return "Hit \(mark.opening), \(title), \(MarrowFigures.daykey(mark.daykey))"
        case .muff(let mark):
            return "Miss \(mark.spoken), \(title), \(MarrowFigures.daykey(mark.daykey))"
        }
    }
}
