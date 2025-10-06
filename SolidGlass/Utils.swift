//
//  Utils.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import AppKit
import Foundation
import SwiftUI

final class Utils {
    
    static let appWarnings: [String: LocalizedStringKey] = [
        "com.apple.Safari": "warning_required_global",
        "com.apple.systempreferences": "warning_required_global",
        "com.apple.apps.launcher": "warning_disabled_effect",
        "com.apple.iBooksX": "warning_nothing_works",
        "com.apple.FaceTime": "warning_weird_ui",
        "com.apple.iWork.Keynote": "warning_weird_ui",
        "com.apple.iWork.Pages": "warning_required_global",
        "com.apple.Passwords": "warning_weird_ui",
        "com.apple.mobilephone": "warning_required_global_and_weird_ui",
        "com.apple.podcasts": "warning_nothing_works",
        "com.apple.dock": "warning_weird_ui",
        "com.apple.controlcenter": "warning_nothing_works",
        "com.apple.AddressBook": "warning_required_global",
        "com.apple.mail": "warning_required_global",
    ]

    static func getAllInstalledApps() -> [InstalledApp] {
        var installedApps: [InstalledApp] = []
        var addedBundleIDs: Set<String> = []

        let applicationDirectories: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/System/Applications/Utilities"),
            URL(fileURLWithPath: "/System/Library/CoreServices"),
            FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!,
        ]

        let fileManager = FileManager.default

        for directory in applicationDirectories {
            guard let enumerator = fileManager.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles],
                errorHandler: nil
            ) else { continue }

            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "app" {
                    if let bundle = Bundle(url: fileURL),
                       let bundleID = bundle.bundleIdentifier,
                       !addedBundleIDs.contains(bundleID) {

                        let appName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                      bundle.infoDictionary?["CFBundleName"] as? String ??
                                      fileURL.deletingPathExtension().lastPathComponent

                        var appIcon: NSImage? = nil
                        if let iconFile = bundle.infoDictionary?["CFBundleIconFile"] as? String {
                            appIcon = bundle.image(forResource: iconFile)
                        }
                        if appIcon == nil {
                            appIcon = NSImage(named: "unknown")
                        }
                        
                        let warning: LocalizedStringKey? = appWarnings[bundleID]

                        let app = InstalledApp(
                            name: appName,
                            bundleIdentifier: bundleID,
                            path: fileURL,
                            icon: appIcon,
                            warning: warning
                        )
                        installedApps.append(app)
                        addedBundleIDs.insert(bundleID)
                    }
                }
            }
        }

        let systemAppsBundleIDs = ["com.apple.Preview", "com.apple.Safari", "com.apple.finder"]
        for bundleID in systemAppsBundleIDs {
            if addedBundleIDs.contains(bundleID) { continue }

            if let urls = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?.takeRetainedValue() as? [URL] {
                for url in urls {
                    if !installedApps.contains(where: { $0.path == url }) {
                        if let bundle = Bundle(url: url) {
                            let appName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                                          bundle.infoDictionary?["CFBundleName"] as? String ??
                                          url.deletingPathExtension().lastPathComponent

                            let warning: LocalizedStringKey? = appWarnings[bundleID]

                            let app = InstalledApp(
                                name: appName,
                                bundleIdentifier: bundle.bundleIdentifier,
                                path: url,
                                icon: NSImage(named: "unknown"),
                                warning: warning
                            )
                            installedApps.append(app)
                            if let bundleID = bundle.bundleIdentifier {
                                addedBundleIDs.insert(bundleID)
                            }
                        }
                    }
                }
            }
        }

        return installedApps
    }

}
