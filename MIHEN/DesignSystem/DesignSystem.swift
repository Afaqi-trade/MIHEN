import SwiftUI

extension Color {
    static let mihenNavy = Color(red: 11/255, green: 34/255, blue: 68/255)
    static let mihenGreen = Color(red: 22/255, green: 139/255, blue: 73/255)
    static let mihenRed = Color(red: 229/255, green: 57/255, blue: 53/255)
    static let mihenBackground = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .systemGroupedBackground : UIColor(red: 247/255, green: 245/255, blue: 239/255, alpha: 1) })
}
struct MihenCard: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24))
    }
}
extension View {
    func mihenCard() -> some View { modifier(MihenCard()) }
}
struct BrandMark: View {
    var body: some View {
        Image("BrandMark").resizable().scaledToFit().accessibilityHidden(true)
    }
}
struct EmptyState: View {
    @Environment(AppStore.self) private var store
    let key: String
    var body: some View {
        ContentUnavailableView(store.t(key), systemImage: "leaf", description: Text(store.t("empty.detail")))
    }
}
struct ValueInput: View {
    @Environment(AppStore.self) private var store
    let title: String
    @Binding var value: Double
    var body: some View {
        HStack {
            Text(store.t(title))
            Spacer()
            TextField(store.t(title), value: $value, format: .number)
                .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                .accessibilityIdentifier(title)
        }
    }
}
struct UnitPicker: View {
    @Environment(AppStore.self) private var store
    @Binding var unit: String
    var body: some View {
        Picker(store.t("unit"), selection: $unit) {
            ForEach(["count", "pages", "minutes", "books", "TRY", "custom"], id: \.self) { Text(store.t($0)).tag($0) }
        }
        if !["count", "pages", "minutes", "books", "TRY"].contains(unit) {
            TextField(store.t("custom.unit"), text: $unit)
        }
    }
}

private struct KeyboardAccessory: ViewModifier {
    @Environment(AppStore.self) private var store
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(store.t("keyboard.done")) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }.accessibilityIdentifier("keyboard.done")
            }
        }.scrollDismissesKeyboard(.interactively)
    }
}
extension View {
    func keyboardDone() -> some View { modifier(KeyboardAccessory()) }
}
