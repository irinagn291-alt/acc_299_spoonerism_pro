import SwiftUI

/// Role: Onset. Named colours from Assets.xcassets. Hex lives only in this accessor: #424714 #656B30 #FFF6FC #E8FF2E #D5DB9E.
enum MarrowInk {
    enum Hex {
        static let background = "#424714"
        static let surface = "#656B30"
        static let ink = "#FFF6FC"
        static let accent = "#E8FF2E"
        static let muted = "#D5DB9E"
    }

    static var background: Color { Color("background") }
    static var surface: Color { Color("surface") }
    static var ink: Color { Color("ink") }
    static var accent: Color { Color("MarrowInk/accent") }
    static var muted: Color { Color("muted") }
}

/// Role: Onset. SF Pro via Font.system as the hospitable short-display type move. Six steps: display, title, headline, body, caption, micro. Never above 34pt, never below 12pt.
enum MarrowType {
    static let face = "SF Pro"

    enum Step: CaseIterable {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, size: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if size >= .accessibility3 {
                return .system(.title2, design: .default).weight(.semibold).leading(.tight)
            }
            return .system(.title, design: .default).weight(.semibold).leading(.tight)
        case .title:
            return .system(.title3, design: .default).weight(.semibold).leading(.tight)
        case .headline:
            return .system(.headline, design: .default).weight(.semibold)
        case .body:
            return .system(.body, design: .default)
        case .caption:
            return .system(.footnote, design: .default).weight(.medium).monospacedDigit()
        case .micro:
            return .system(.caption, design: .default).monospacedDigit()
        }
    }
}

/// Role: Onset. One 8pt grid. Hits are 44pt. Views never pick a stray padding. Comfortable Airbnb density: outer > card > inner.
enum MarrowSpace {
    static let unit: CGFloat = 8

    static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    static var hit: CGFloat { 44 }
    static var outer: CGFloat { step(3) }
    static var card: CGFloat { step(2) }
    static var inner: CGFloat { step(1) }
    static var gap: CGFloat { step(1) }
}

/// Role: Onset. Cards and sheets 20pt, chips 12pt. Never a second radius language.
enum MarrowRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

/// Role: Onset. One soft drop-shadow. Only the Quiz hero sits above the field.
enum MarrowLift {
    static let shadeRadius: CGFloat = 16
    static let shadeY: CGFloat = 8
    static var shade: Color { MarrowInk.ink.opacity(0.12) }
}
