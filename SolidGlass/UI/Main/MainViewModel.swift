//
//  MainViewModel.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class MainViewModel: ObservableObject {

    @Published var solariumStates: [String: Bool] = [:]
    @Published var solariumForcedStates: [String: Bool] = [:] // NOVO
    @Published var isLoading = true
    @Published var globalDisabled = false
    @Published var globalForced = false
    @Published var loadingDescription: String = String(localized: "loading")

    @AppStorage(StorageKeys.appleList) private var appleList = false
    
    private let appWarnings: [String: LocalizedStringKey] = [
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

    var appData: AppData

    init(appData: AppData) {
        self.appData = appData
        Task {
            if appData.apps.isEmpty {
                await loadApps()
            }
            globalDisabled = Self.isGlobalSolariumDisabled()
            globalForced = Self.isGlobalSolariumForced()
        }
    }

    func filteredApps(_ searchText: String) -> [MacApp] {
        var apps = appData.apps

        if appleList {
            apps = apps.filter { $0.bundleIdentifier?.contains("com.apple") == true }
        }

        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return apps
    }

    func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
        
    func getAllInstalledApps() -> [MacApp] {
        
        let fileManager = FileManager.default
        let appDirectories = [
            "/Applications",
            "/System/Applications",
            "\(NSHomeDirectory())/Applications"
        ]
        
        var apps: [MacApp] = []
        
        for directory in appDirectories {
            loadingDescription = String(format: NSLocalizedString("checking_directory", comment: ""), directory)
            
            let url = URL(fileURLWithPath: directory)
            guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
                loadingDescription = String(format: NSLocalizedString("directory_access_failed", comment: ""), directory)
                continue
            }
            
            for (index, item) in contents.enumerated() where item.pathExtension == "app" {
                loadingDescription = String(format: NSLocalizedString("reading_app_from_directory", comment: ""), index + 1, contents.count, directory)
                
                let bundle = Bundle(url: item)
                let name = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                    ?? item.deletingPathExtension().lastPathComponent
                let bundleIdentifier = bundle?.bundleIdentifier
                let icon = NSWorkspace.shared.icon(forFile: item.path)
                icon.size = NSSize(width: 64, height: 64)
                
                let app = MacApp(
                    name: name,
                    bundleIdentifier: bundleIdentifier,
                    path: item,
                    icon: icon,
                    warning: appWarnings[bundleIdentifier ?? ""]
                )
                
                apps.append(app)
            }
        }
        
        loadingDescription = NSLocalizedString("sorting_apps", comment: "")
        let sortedApps = apps.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        
        loadingDescription = String(format: NSLocalizedString("loading_completed", comment: ""), sortedApps.count)
        return sortedApps
    }

    func loadApps() async {
        isLoading = true
        let allApps = getAllInstalledApps()

        await withTaskGroup(of: Void.self) { group in
            for app in allApps {
                guard let bundle = app.bundleIdentifier else { continue }
                group.addTask {
                    let disabled = await Self.isAppSolariumDisabled(bundle: bundle)
                    let forced = await Self.isAppSolariumForced(bundle: bundle)
                    await MainActor.run {
                        self.solariumStates[bundle] = disabled
                        self.solariumForcedStates[bundle] = forced
                    }
                }
            }
        }

        await MainActor.run {
            appData.apps = allApps
            self.isLoading = false
        }
    }

    func toggleAppSolarium(for bundle: String, deactivate: Bool) {
        Task.detached {
            await Self.runDefaultsCommand(for: bundle, deactivate: deactivate)
        }
        solariumStates[bundle] = deactivate
    }

    func toggleAppForceSolarium(for bundle: String, force: Bool) {
        Task.detached {
            await Self.runDefaultsForceCommand(for: bundle, force: force)
        }
        solariumForcedStates[bundle] = force
    }

    func toggleGlobalSolarium(deactivate: Bool) {
        globalDisabled = deactivate
        Task.detached {
            await Self.runDefaultsCommand(for: "-g", deactivate: deactivate)
        }
    }

    func toggleGlobalForceSolarium(force: Bool) {
        globalForced = force
        Task.detached {
            await Self.runDefaultsForceCommand(for: "-g", force: force)
        }
    }

    static func runDefaultsCommand(for bundle: String, deactivate: Bool) {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = [
            "write", bundle, "com.apple.SwiftUI.DisableSolarium", "-bool", deactivate ? "YES" : "NO"
        ]
        try? process.run()
        process.waitUntilExit()
    }

    static func runDefaultsForceCommand(for bundle: String, force: Bool) {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = [
            "write", bundle, "com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck", "-bool", force ? "YES" : "NO"
        ]
        try? process.run()
        process.waitUntilExit()
    }

    static func isAppSolariumDisabled(bundle: String) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", bundle, "com.apple.SwiftUI.DisableSolarium"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try? process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return false }
        return output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "1"
    }

    static func isAppSolariumForced(bundle: String) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", bundle, "com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try? process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return false }
        return output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "1"
    }

    static func isGlobalSolariumDisabled() -> Bool {
        return isAppSolariumDisabled(bundle: "-g")
    }

    static func isGlobalSolariumForced() -> Bool {
        return isAppSolariumForced(bundle: "-g")
    }
}
