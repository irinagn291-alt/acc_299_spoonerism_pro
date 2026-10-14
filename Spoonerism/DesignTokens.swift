import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #424714
    static let bg = Color(red: 0.258824, green: 0.278431, blue: 0.078431)
    static let bgHex = "#424714"
    /// #656B30
    static let surface = Color(red: 0.396078, green: 0.419608, blue: 0.188235)
    static let surfaceHex = "#656B30"
    /// #FFF6FC
    static let ink = Color(red: 1, green: 0.964706, blue: 0.988235)
    static let inkHex = "#FFF6FC"
    /// #E8FF2E
    static let accent = Color(red: 0.909804, green: 1, blue: 0.180392)
    static let accentHex = "#E8FF2E"
    /// #D5DB9E
    static let muted = Color(red: 0.835294, green: 0.858824, blue: 0.619608)
    static let mutedHex = "#D5DB9E"
    static let fontFamily = "SF Pro"
}
