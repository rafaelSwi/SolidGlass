//
//  FlagToggleGroup.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth on 21/10/25.
//

import SwiftUI

struct FlagToggleGroup: View {
    let bundle: String
    let app: MacApp
    let autoRestartApp: Bool
    let restartApp: (MacApp) -> Void
    @ObservedObject var viewModel: MainViewModel

    @State private var expanded = false

    private var activeFlagsCount: Int {
        viewModel.solariumFlags[bundle]?.values.filter { $0 }.count ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.05)) {
                    expanded.toggle()
                }
            }) {
                HStack(spacing: 11.5) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.accentColor)
                        .imageScale(.small)

                    Text("software_flags")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(String(localized: "active_flags") + ": \(activeFlagsCount)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(activeFlagsCount > 0 ? .green : .gray)
                        .padding(.horizontal, 7)
                        .background(
                            Capsule()
                                .fill(activeFlagsCount > 0 ? Color.green.opacity(0.15) : Color.secondary.opacity(0.08))
                        )
                }
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(spacing: 4) {
                    ForEach(FlagType.allCases, id: \.self) { flag in
                        FlagToggleButton(
                            bundle: bundle,
                            flag: flag,
                            autoRestartApp: autoRestartApp,
                            app: app,
                            viewModel: viewModel
                        )
                    }
                }
                .transition(
                    .opacity
                    .combined(with: .move(edge: .top))
                    .animation(.easeInOut(duration: 0.10))
                )
            }
        }
    }
}
