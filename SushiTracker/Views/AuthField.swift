import SwiftUI

// Shared glass text field for Login and SignUp screens
struct AuthField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundStyle(.white)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(keyboard == .emailAddress ? .none : .words)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
            }
        }
        .placeholder(when: text.isEmpty) {
            Text(placeholder).foregroundStyle(.white.opacity(0.45))
        }
        .padding(18)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
