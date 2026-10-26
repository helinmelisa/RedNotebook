import SwiftUI

/// Tapping anywhere that isn't a text field puts the keyboard away, all over the app (sheets too).
/// Installed once on the window; it watches taps without taking them from buttons and stickers.
struct TapToDismissKeyboard: UIViewRepresentable {
    func makeUIView(context: Context) -> InstallerView {
        InstallerView()
    }

    func updateUIView(_ uiView: InstallerView, context: Context) {}

    final class InstallerView: UIView, UIGestureRecognizerDelegate {
        private lazy var tap: UITapGestureRecognizer = {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            tap.cancelsTouchesInView = false
            tap.delegate = self
            return tap
        }()

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let window, tap.view !== window {
                window.addGestureRecognizer(tap)
            }
        }

        @objc private func tapped() {
            // Only a text field's keyboard; the drawing canvas also holds first responder for its pen palette
            guard let typing = UIResponder.currentFirstResponder, typing is UITextInput else { return }
            // A tap that moved the cursor to another field (a button that starts a new line, say) wins
            DispatchQueue.main.async {
                if UIResponder.currentFirstResponder === typing {
                    typing.resignFirstResponder()
                }
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // Taps inside a text field place the cursor
            var view = touch.view
            while let current = view {
                if current is UITextInput { return false }
                view = current.superview
            }
            return true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

private extension UIResponder {
    private static weak var found: UIResponder?

    /// Whatever has the keyboard right now.
    static var currentFirstResponder: UIResponder? {
        found = nil
        UIApplication.shared.sendAction(#selector(reportAsFirstResponder), to: nil, from: nil, for: nil)
        return found
    }

    @objc private func reportAsFirstResponder() {
        UIResponder.found = self
    }
}
