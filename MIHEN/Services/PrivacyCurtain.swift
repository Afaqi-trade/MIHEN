import UIKit

/// A window-level cover also protects sheets in the app switcher.
/// It contains no user data and is removed only when the app is active again.
@MainActor final class PrivacyCurtain: NSObject {
    static let shared = PrivacyCurtain()
    private var covers: [UIView] = []
    private weak var store: AppStore?
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self,selector:#selector(hideContent(_:)),name:UIApplication.willResignActiveNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(revealContent(_:)),name:UIApplication.didBecomeActiveNotification,object:nil)
    }
    func attach(_ store: AppStore) { self.store = store }
    @objc private func hideContent(_ notification: Notification) {
        if store?.preferences.lockEnabled == true { store?.locked = true }
        guard covers.isEmpty else { return }
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows where window.isKeyWindow {
                let cover = UIView(frame:window.bounds)
                cover.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                cover.backgroundColor = .systemBackground
                let label = UILabel(); label.text = "MİHEN"; label.font = .preferredFont(forTextStyle:.largeTitle)
                label.translatesAutoresizingMaskIntoConstraints = false; cover.addSubview(label)
                NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo:cover.centerXAnchor),label.centerYAnchor.constraint(equalTo:cover.centerYAnchor)])
                window.addSubview(cover); covers.append(cover)
            }
        }
    }
    @objc private func revealContent(_ notification: Notification) { covers.forEach { $0.removeFromSuperview() }; covers = [] }
}
