import Foundation

enum Localization {
    static func recordTitle(_ title: String, language: String) -> String {
        guard title.hasPrefix("template.") || title.hasPrefix("routine.") else { return title }
        return text(title, language: language)
    }
    static func text(_ key: String, language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }
}
