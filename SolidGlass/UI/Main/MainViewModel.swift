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
    @Published var solariumFlags: [String: [FlagType: Bool]] = [:]
    @Published var globalStates: [FlagType: Bool] = [:]
    @Published var isLoading = true
    @Published var loadingDescription: String = String(localized: "loading")
    @Published var globalDisabled = false
    @Published var globalForced = false

    @AppStorage(StorageKeys.appleList) private var appleList = false

    var appData: AppData

    init(appData: AppData) {
        self.appData = appData

        Task {
            if appData.apps.isEmpty {
                await loadApps()
            }

            for flag in FlagType.allCases {
                let enabled = Self.isFlagEnabled(bundle: "-g", flag: flag)
                globalStates[flag] = enabled
            }

            globalDisabled = globalStates[.disableSolarium] ?? false
            globalForced = globalStates[.ignoreSolariumLinkedOnCheck] ?? false
        }
    }

    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
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

    func getAllInstalledApps() -> [MacApp] {
        
        @AppStorage(StorageKeys.acceptedTerms) var acceptedTerms = false
        
        if (!acceptedTerms) {
            return []
        }
        
        let fileManager = FileManager.default
        let appDirectories = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            "/System/Library/CoreServices",
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
                    icon: icon
                )

                apps.append(app)
            }
        }

        loadingDescription = NSLocalizedString("sorting_apps", comment: "")
        let sortedApps = apps.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }

        loadingDescription = String(format: NSLocalizedString("loading_completed", comment: ""), sortedApps.count)
        return sortedApps
    }
    
    func restartSolidGlass() {
        let path = Bundle.main.bundlePath
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        NSApplication.shared.terminate(nil)
    }

    func loadApps() async {
        isLoading = true
        let allApps = getAllInstalledApps()
 
        await withTaskGroup(of: Void.self) { group in
            for app in allApps {
                guard let bundle = app.bundleIdentifier else { continue }

                group.addTask {
                    var flagMap: [FlagType: Bool] = [:]

                    for flag in FlagType.allCases {
                        let enabled = await Self.isFlagEnabled(bundle: bundle, flag: flag)
                        flagMap[flag] = enabled
                    }

                    await MainActor.run {
                        var current = self.solariumFlags[bundle] ?? [:]
                        current.merge(flagMap) { _, new in new }
                        self.solariumFlags[bundle] = current
                    }
                }
            }
        }

        await MainActor.run {
            appData.apps = allApps
            isLoading = false
        }
    }
    
    func toggleFlag(for bundle: String, flag: FlagType, active: Bool) {
        Task.detached {
            await Self.runDefaultsCommand(for: bundle, flag: flag, active: active)
        }

        Task { @MainActor in
            var current = solariumFlags[bundle] ?? [:]
            current[flag] = active
            solariumFlags[bundle] = current
        }
    }

    func toggleGlobalFlag(flag: FlagType, active: Bool) {
        Task.detached {
            await Self.runDefaultsCommand(for: "-g", flag: flag, active: active)
        }

        Task { @MainActor in
            globalStates[flag] = active
            if flag == .disableSolarium { globalDisabled = active }
            if flag == .ignoreSolariumLinkedOnCheck { globalForced = active }
        }
    }

    func toggleGlobalSolarium(active: Bool) {
        toggleGlobalFlag(flag: .disableSolarium, active: active)
    }

    static func runDefaultsCommand(for bundle: String, flag: FlagType, active: Bool) {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = [
            "write", bundle, "com.apple.SwiftUI.\(flag.rawValue)", "-bool", active ? "YES" : "NO"
        ]
        try? process.run()
        process.waitUntilExit()
    }

    static func isFlagEnabled(bundle: String, flag: FlagType) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", bundle, "com.apple.SwiftUI.\(flag.rawValue)"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try? process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return false }
        return output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "1"
    }
}
