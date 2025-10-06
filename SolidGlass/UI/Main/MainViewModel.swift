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
    @Published var isLoading = true
    @Published var globalDisabled = false
    
    @AppStorage(StorageKeys.appleList) private var appleList = false
    
    var appData: AppData
    
    init(appData: AppData) {
        self.appData = appData
        Task {
            if (appData.apps.isEmpty) {
                await loadApps()
            }
            globalDisabled = Self.isGlobalSolariumDisabled()
        }
    }
    
    func filteredApps(_ searchText: String) -> [InstalledApp] {
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

    func loadApps() async {
        isLoading = true
        let allApps = Utils.getAllInstalledApps()

        await withTaskGroup(of: Void.self) { group in
            for app in allApps {
                guard let bundle = app.bundleIdentifier else { continue }
                group.addTask {
                    let state = await Self.isAppSolariumDisabled(bundle: bundle)
                    await MainActor.run {
                        self.solariumStates[bundle] = state
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

    func toggleGlobalSolarium(deactivate: Bool) {
        globalDisabled = deactivate
        Task.detached {
            await Self.runDefaultsCommand(for: "-g", deactivate: deactivate)
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

    static func isGlobalSolariumDisabled() -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/defaults"
        process.arguments = ["read", "-g", "com.apple.SwiftUI.DisableSolarium"]

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
