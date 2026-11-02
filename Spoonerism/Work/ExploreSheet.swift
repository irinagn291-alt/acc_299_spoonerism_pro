import SwiftUI

/// Role: Work. Explore screen. Prado shelf writes an Idle Work. Bundled shelf when query is empty or search fails. Arrives as a sheet over Quiz.
struct ExploreView: View {
    @Bindable var desk: OnsetDesk
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var searchFocused: Bool

    var body: some View {
        MarrowSheetHost {
            NavigationStack {
                Group {
                    if desk.exploreIsEmpty, desk.seekFault != nil {
                        errorPage
                    } else if desk.exploreIsEmpty {
                        emptyPage
                    } else {
                        populated
                    }
                }
                .background(MarrowInk.background.ignoresSafeArea())
                .navigationTitle("Gallery")
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
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { searchFocused = false }
                            .font(MarrowType.font(.caption, size: typeSize))
                            .foregroundStyle(MarrowInk.ink)
                    }
                }
                .safeAreaInset(edge: .top, spacing: MarrowSpace.gap) {
                    searchField
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .task {
            if desk.seekHits.isEmpty {
                desk.scheduleSeek()
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: MarrowSpace.inner) {
            Text("Museo Nacional del Prado")
                .font(MarrowType.font(.micro, size: typeSize))
                .foregroundStyle(MarrowInk.muted)
                .padding(.horizontal, MarrowSpace.outer)
            HStack(spacing: MarrowSpace.gap) {
                Image(systemName: "magnifyingglass").foregroundStyle(MarrowInk.muted)
                TextField("Search paintings or artists", text: $desk.query)
                    .font(MarrowType.font(.body, size: typeSize))
                    .foregroundStyle(MarrowInk.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .onChange(of: desk.query) { _, _ in
                        desk.scheduleSeek()
                    }
                    .onSubmit {
                        searchFocused = false
                    }
                if desk.isSeeking {
                    ProgressView()
                        .tint(MarrowInk.ink)
                        .frame(width: MarrowSpace.hit, height: MarrowSpace.hit)
                }
            }
            .padding(MarrowSpace.card)
            .frame(minHeight: MarrowSpace.hit)
            .marrowFlat()
            .padding(.horizontal, MarrowSpace.outer)
            if let note = desk.shelfNote {
                Text(note)
                    .font(MarrowType.font(.micro, size: typeSize))
                    .foregroundStyle(MarrowInk.muted)
                    .padding(.horizontal, MarrowSpace.outer)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let fault = desk.seekFault, !desk.seekHits.isEmpty {
                HStack(alignment: .center, spacing: MarrowSpace.gap) {
                    Text(fault)
                        .font(MarrowType.font(.micro, size: typeSize))
                        .foregroundStyle(MarrowInk.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Retry") {
                        desk.scheduleSeek()
                    }
                    .font(MarrowType.font(.caption, size: typeSize))
                    .foregroundStyle(MarrowInk.ink)
                    .marrowHit()
                    .buttonStyle(MarrowGlyphStyle())
                    .accessibilityLabel("Retry search")
                }
                .padding(MarrowSpace.inner)
                .frame(maxWidth: .infinity, alignment: .leading)
                .marrowFlat()
                .padding(.horizontal, MarrowSpace.outer)
            }
        }
        .padding(.bottom, MarrowSpace.gap)
        .background(MarrowInk.background)
    }

    private var populated: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 16)], spacing: 20) {
                    ForEach(desk.seekHits) { row in
                        Button {
                            searchFocused = false
                            Task { await desk.keepWork(row) }
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                QuizTile(work: Work.idle(from: row, daykey: desk.dayStamp), showSuccess: false)
                                    .frame(height: 200)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(row.title)
                                        .font(.system(.title3, design: .serif).weight(.medium))
                                        .foregroundStyle(MarrowInk.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(row.artist)
                                        .font(.subheadline)
                                        .foregroundStyle(MarrowInk.muted)
                                    HStack {
                                        Text(row.dated ?? "Prado collection").font(.caption)
                                            .foregroundStyle(MarrowInk.muted)
                                        Spacer()
                                        if desk.stockingObjectID == row.objectID {
                                            ProgressView().tint(MarrowInk.accent)
                                        } else {
                                            Label(isKept(row) ? "Saved" : "Save painting", systemImage: isKept(row) ? "checkmark.circle.fill" : "plus.circle")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(MarrowInk.accent)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                .padding(16)
                            }
                            .background(MarrowInk.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(MarrowInk.ink.opacity(0.06)))
                        }
                        .buttonStyle(MarrowRowStyle())
                        .disabled(desk.stockingObjectID != nil)
                        .id(row.objectID)
                        .accessibilityLabel("\(row.title), \(row.artist), \(isKept(row) ? "saved" : "save painting")")
                    }
                }
                .padding(20)
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .onChange(of: desk.focusedObjectID) { _, objectID in
                guard let objectID else { return }
                withAnimation(MarrowMotion.snap(reduceMotion)) { proxy.scrollTo(objectID, anchor: .center) }
            }
        }
    }

    private func isKept(_ row: CatalogRow) -> Bool {
        desk.onset.works.contains { $0.objectID == row.objectID }
    }

    private var emptyPage: some View {
        ShelfQuiet(
            art: MarrowArt.emptyList,
            headline: MarrowCopy.exploreEmptyHeadline,
            line: MarrowCopy.exploreEmptyLine,
            actionTitle: "Retry"
        ) {
            desk.scheduleSeek()
        }
    }

    private var errorPage: some View {
        ShelfQuiet(
            art: MarrowArt.emptyList,
            headline: "Search could not finish.",
            line: desk.seekFault ?? MarrowCopy.seek(.transport),
            actionTitle: "Retry"
        ) {
            desk.scheduleSeek()
        }
    }
}

/// Role: Work. Same Explore screen. Named for the live driver key explore.
struct Explore: View {
    @Bindable var desk: OnsetDesk

    var body: some View {
        ExploreView(desk: desk)
    }
}
