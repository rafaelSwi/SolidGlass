//
//  AppRow.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI

struct AppRow: View {
    let app: MacApp
    @ObservedObject var viewModel: MainViewModel
    let compactMode: Bool
    let showIcon: Bool
    
    @AppStorage(StorageKeys.legacy) private var legacy = false
    @AppStorage(StorageKeys.autoRestartApp) private var autoRestartApp = false
    
    @State private var showingWarning = false
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 8) {
            
            if showIcon {
                Image(nsImage: app.icon ?? NSImage(named: "unknown")!)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(app.name)
                        .font(.subheadline)
                    
                    if !compactMode, let bundle = app.bundleIdentifier {
                        Text(bundle)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if !legacy {
                    FlagToggleGroup(
                        bundle: app.bundleIdentifier ?? "",
                        app: app,
                        autoRestartApp: autoRestartApp,
                        restartApp: restartApp,
                        viewModel: viewModel
                    )
                }
            }
            
            Spacer()
            
            if let bundle = app.bundleIdentifier {
                
                if (legacy) {
                    HStack(spacing: 12) {
                        Toggle("disable_liquid_glass", isOn: Binding(
                            get: { viewModel.solariumFlags[bundle]?[.disableSolarium] ?? false },
                            set: { newValue in
                                viewModel.toggleFlag(for: bundle, flag: .disableSolarium, active: newValue)
                                viewModel.solariumFlags[bundle]?[.disableSolarium] = newValue
                                if autoRestartApp { restartApp(app: app) }
                            }
                        ))
                        .toggleStyle(.checkbox)

                        Toggle("force_liquid_glass", isOn: Binding(
                            get: { viewModel.solariumFlags[bundle]?[.ignoreSolariumLinkedOnCheck] ?? false },
                            set: { newValue in
                                viewModel.toggleFlag(for: bundle, flag: .ignoreSolariumLinkedOnCheck, active: newValue)
                                viewModel.solariumFlags[bundle]?[.ignoreSolariumLinkedOnCheck] = newValue
                                if autoRestartApp { restartApp(app: app) }
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                }
            }
        }
        .padding(.vertical, 2)
        .contextMenu {
            Button("open") { NSWorkspace.shared.open(app.path) }
            Button("restart") { restartApp(app: app) }
            Button("show_on_finder") { NSWorkspace.shared.activateFileViewerSelecting([app.path]) }
            
            if let bundle = app.bundleIdentifier {
                Button("copy_bundle_identifier") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(bundle, forType: .string)
                }
            }
        }
    }
    
    private func restartApp(app: MacApp) {
        guard let bundleID = app.bundleIdentifier else { return }
        let runningApps = NSWorkspace.shared.runningApplications
        if let runningApp = runningApps.first(where: { $0.bundleIdentifier == bundleID }) {
            runningApp.terminate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSWorkspace.shared.open(app.path)
            }
        }
    }
}
