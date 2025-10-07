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
    
    @AppStorage(StorageKeys.autoRestartApp) private var autoRestartApp = false
    @AppStorage(StorageKeys.showForceEffect) private var showForceEffect = false
    
    @State private var showingWarning = false
    
    var body: some View {
        
        HStack(spacing: 8) {
            
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
                    
                    if let warning = app.warning {
                        Button(action: { showingWarning = true }) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alert(isPresented: $showingWarning) {
                            Alert(
                                title: Text("warning"),
                                message: Text(warning),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    if !compactMode, let bundle = app.bundleIdentifier {
                        Text(bundle)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if let bundle = app.bundleIdentifier {
                
                if (showForceEffect) {
                    
                    HStack(spacing: 12) {
                        Toggle("disable_liquid_glass", isOn: Binding(
                            get: { viewModel.solariumStates[bundle] ?? false },
                            set: { newValue in
                                viewModel.toggleAppSolarium(for: bundle, deactivate: newValue)
                                viewModel.solariumStates[bundle] = newValue
                                if autoRestartApp { restartApp(app: app) }
                            }
                        ))
                        .toggleStyle(.checkbox)
                        
                        Toggle("force_liquid_glass", isOn: Binding(
                            get: { viewModel.solariumForcedStates[bundle] ?? false },
                            set: { newValue in
                                viewModel.toggleAppForceSolarium(for: bundle, force: newValue)
                                viewModel.solariumForcedStates[bundle] = newValue
                                if autoRestartApp { restartApp(app: app) }
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                } else {
                    let isDisabled = viewModel.solariumStates[bundle] ?? false
                    Toggle(isOn: Binding(
                        get: { viewModel.solariumStates[bundle] ?? false },
                        set: { newValue in
                            viewModel.toggleAppSolarium(for: bundle, deactivate: newValue)
                            viewModel.solariumStates[bundle] = newValue
                            if autoRestartApp { restartApp(app: app) }
                        }
                    )) {
                        Text(isDisabled ? "disabled" : "default")
                    }
                    .toggleStyle(.switch)
                    .frame(width: 150)
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
