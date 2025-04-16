import SwiftUI

struct InterceptBackButtonKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var interceptBackButton: Bool {
        get { self[InterceptBackButtonKey.self] }
        set { self[InterceptBackButtonKey.self] = newValue }
    }
}

class BackButtonHandler: NSObject {
    private let hasUnsavedChanges: Bool
    private let showExitConfirmation: (Bool) -> Void
    private let dismiss: () -> Void
    
    init(hasUnsavedChanges: Bool, showExitConfirmation: @escaping (Bool) -> Void, dismiss: @escaping () -> Void) {
        self.hasUnsavedChanges = hasUnsavedChanges
        self.showExitConfirmation = showExitConfirmation
        self.dismiss = dismiss
        super.init()
    }
    
    @objc func backButtonPressed() {
        if hasUnsavedChanges {
            showExitConfirmation(true)
        } else {
            dismiss()
        }
    }
}

// New Modifier using Toolbar
struct ConfirmExitOnBackModifier: ViewModifier {
    let hasUnsavedChanges: Bool
    @Binding var showExitConfirmation: Bool

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(hasUnsavedChanges) // Hide native button when changes exist
            .interactiveDismissDisabled(hasUnsavedChanges) // Prevent swipe gesture when changes exist
            .toolbar {
                if hasUnsavedChanges {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // Trigger the confirmation dialog
                            showExitConfirmation = true
                        } label: {
                            // Standard back button appearance
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
                // No need for an else, if !hasUnsavedChanges, the native button is shown
            }
    }
}

extension View {
    /// Applies a modifier that shows a confirmation dialog when trying to navigate back
    /// with unsaved changes. It hides the native back button and replaces it with a
    /// custom one that triggers the dialog when `hasUnsavedChanges` is true.
    /// It also disables the interactive dismiss gesture (swipe back).
    func confirmExitOnBack(
        if hasUnsavedChanges: Bool,
        showConfirmationDialog: Binding<Bool>
    ) -> some View {
        modifier(ConfirmExitOnBackModifier(
            hasUnsavedChanges: hasUnsavedChanges,
            showExitConfirmation: showConfirmationDialog
        ))
    }
}

