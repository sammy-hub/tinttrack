import Foundation

enum CloudSyncPreferences {
    private static let key = "iCloudSyncEnabled"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
