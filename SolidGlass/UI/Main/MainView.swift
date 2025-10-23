//
//  MainView.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI
import AppKit

struct MainView: View {
    
    @Binding var currentWindow: AppWindow
    @StateObject var viewModel: MainViewModel
    
    @AppStorage(StorageKeys.legacy) private var legacy = false
    @AppStorage(StorageKeys.hideAppIcons) private var hideAppIcons = true
    @AppStorage(StorageKeys.showBundle) private var showBundle = false
    @AppStorage(StorageKeys.acceptedTerms) private var acceptedTerms = false
    @AppStorage(StorageKeys.hideWarning) private var hideWarning = false
    
    @State private var searchText = ""
    @State private var showingAddAppSheet = false
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 16) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("SolidGlass")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("v\(viewModel.appVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if (legacy) {
                        Text("legacy_mode")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { currentWindow = .settings }) {
                            Label("settings", systemImage: "gear")
                        }
                        
                        
                        Button(action: { showingAddAppSheet.toggle() }) {
                            Label("add_app", systemImage: "plus")
                        }
                        
                    }
                }
                .padding(.horizontal)
                
                
                if (legacy) {
                    Form {
                        Section {
                            RedToggle(isOn: $viewModel.globalDisabled,
                                      title: NSLocalizedString("disable_globally", comment: ""),
                                      subtitle: String(localized: "restart_could_be_required"),
                                      isLoading: viewModel.isLoading,
                                      onToggle: { value in viewModel.toggleGlobalSolarium(active: value) }
                            )
                        }
                    }
                }
                
                if (!hideWarning && acceptedTerms) {
                    WarningView(title: "main_warning_title", hoverMessage: "main_warning_body")
                        .contextMenu {
                            Button("hide") {
                                hideWarning = true
                            }
                        }
                }
                
                TextField("search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView(String(localized: "\(viewModel.loadingDescription)"))
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredApps(searchText), id: \.bundleIdentifier) { app in
                            AppRow(
                                app: app,
                                viewModel: viewModel,
                                compactMode: !showBundle,
                                showIcon: !hideAppIcons
                            )
                        }
                    }
                }
            }
            .disabled(!acceptedTerms)
            
            if !acceptedTerms {
                TermsView(
                    title: String(localized: "terms_of_use"),
                    message: Terms.english,
                    agreeTitle: String(localized: "agree"),
                    disagreeTitle: String(localized: "disagree"),
                    onAgree: {
                        acceptedTerms = true
                        viewModel.restartSolidGlass()
                    },
                    onDisagree: {
                        NSApplication.shared.terminate(nil)
                    }
                )
            }
            
        }
        .padding(.vertical)
        .frame(minWidth: 600, minHeight: 600)
        .sheet(isPresented: $showingAddAppSheet) {
            AddAppSheet(viewModel: viewModel)
        }
    }
    
}

