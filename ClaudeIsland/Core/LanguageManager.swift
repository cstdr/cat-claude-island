//
//  LanguageManager.swift
//  ClaudeIsland
//
//  Runtime language switching support
//

import SwiftUI
import Combine

/// Manages the app's language setting and provides localized strings
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String? {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "language")
            if let lang = currentLanguage {
                UserDefaults.standard.set([lang], forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            }
            // Force UI refresh by updating refreshTrigger
            refreshTrigger += 1
        }
    }

    /// Used to force UI refresh when language changes
    @Published var refreshTrigger: Int = 0

    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: "language")
    }

    /// Returns a localized string for the given key
    func localized(_ key: String) -> String {
        let bundle = Bundle.main
        if let lang = currentLanguage, let languageBundle = bundle.path(forResource: lang, ofType: "lproj")
            .flatMap({ Bundle(path: $0) }) {
            return languageBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    /// Returns a localized string with format arguments
    func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: arguments)
    }
}

// MARK: - String Extension for Localization

extension String {
    /// Localized version of this string using LanguageManager
    var localized: String {
        LanguageManager.shared.localized(self)
    }
}
