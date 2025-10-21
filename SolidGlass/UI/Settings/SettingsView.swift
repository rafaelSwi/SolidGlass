//
//  SettingsView.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.openURL) var openURL
    @StateObject var viewModel = SettingsViewModel()
    
    @Binding var currentWindow: AppWindow
    
    @AppStorage(StorageKeys.legacy) private var legacy = false
    @AppStorage(StorageKeys.hideAppIcons) private var hideAppIcons = true
    @AppStorage(StorageKeys.showBundle) private var showBundle = false
    @AppStorage(StorageKeys.autoRestartApp) private var autoRestartApp = false
    @AppStorage(StorageKeys.appleList) private var appleList = false
    @AppStorage(StorageKeys.hideWarning) private var hideWarning = false
    
    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                if viewModel.updateAvailable, let releaseURL = viewModel.releaseURL {
                    HStack(alignment: .center, spacing: 6) {
                        Button(action: {
                            viewModel.updateAvailable = false
                            viewModel.latestVersion = ""
                        }) {
                            Image(systemName: "x.circle")
                        }
                        
                        Link("\(String(localized: "open_download_page")) (v\(viewModel.latestVersion))", destination: releaseURL)
                            .buttonStyle(.borderedProminent)
                    }
                }
                
                if (!viewModel.updateAvailable) {
                    Button {
                        viewModel.checkForUpdate()
                    } label: {
                        if viewModel.checkingUpdate {
                            ProgressView()
                        } else {
                            Label(!viewModel.latestVersion.isEmpty ? "updated" : "check_for_updates", systemImage: "checkmark.circle")
                        }
                    }
                    .contextMenu {
                        Button {
                            viewModel.checkForUpdate()
                        } label: {
                            Label("check_for_updates", systemImage: "magnifyingglass")
                        }
                        Button {
                            if let url = URL(string: "https://github.com/rafaelSwi/SolidGlass") {
                                openURL(url)
                            }
                        } label: {
                            Label("open_github_page", systemImage: "globe")
                        }
                    }
                }
                
                Button(action: { currentWindow = .donate }) {
                    Label("donate", systemImage: "hand.thumbsup.circle")
                }
                
            }
            
            
            HStack {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Toggle(isOn: $legacy) {
                        Text("legacy_mode")
                    }
                    
                    Text("legacy_mode_description")
                        .font(.footnote)
                        .opacity(0.7)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    Toggle(isOn: $appleList) {
                        Text("apple_list")
                    }
                    
                    Toggle(isOn: $autoRestartApp) {
                        Text("auto_restart_app")
                    }
                    
                    Toggle(isOn: $hideAppIcons) {
                        Text("hide_app_icons")
                    }
                    
                    Toggle(isOn: $showBundle) {
                        Text("show_app_bundle")
                    }
                    
                }
                
                Spacer()
                
            }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button {
                    currentWindow = .main
                } label: {
                    Label("back", systemImage: "arrow.uturn.backward")
                }
                
            }
            
            
        }
        .padding()
        .frame(minWidth: 600, minHeight: 600)
    }
}
