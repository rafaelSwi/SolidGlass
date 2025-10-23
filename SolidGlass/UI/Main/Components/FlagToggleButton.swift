//
//  FlagToggleButton.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth on 21/10/25.
//

import SwiftUI

struct FlagToggleButton: View {
    let bundle: String
    let flag: FlagType
    let autoRestartApp: Bool
    let app: MacApp
    @ObservedObject var viewModel: MainViewModel
    
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

    var body: some View {
        let enabled = viewModel.solariumFlags[bundle]?[flag] ?? false
            
        ZStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(enabled ? Color.green.opacity(0.8) : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle().stroke(enabled ? Color.green : Color.gray.opacity(0.6), lineWidth: 1)
                    )
                
                Text(flag.rawValue)
                    .font(.system(size: 13, weight: enabled ? .semibold : .regular, design: .monospaced))
                    .foregroundColor(enabled ? .primary : .secondary)
                
                if flag == .disableSolarium {
                    Text("deprecated")
                        .foregroundStyle(enabled ? .red : .gray)
                        .font(.callout)
                }
                
                if flag == .ignoreSolariumLinkedOnCheck {
                    Text("force_liquid_glass")
                        .foregroundStyle(enabled ? .blue : .gray)
                        .font(.callout)
                }
                
                Spacer()
                
                Text(LocalizedStringKey(enabled ? "enabled" : "disabled"))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(enabled ? .green : .gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(enabled ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                    )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(enabled ? Color.green.opacity(0.08) : Color.gray.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(enabled ? Color.green.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .onTapGesture {
            viewModel.toggleFlag(for: bundle, flag: flag, active: !enabled)
            viewModel.solariumFlags[bundle]?[flag] = !enabled
            if autoRestartApp { restartApp(app: app) }
        }
    }
}
