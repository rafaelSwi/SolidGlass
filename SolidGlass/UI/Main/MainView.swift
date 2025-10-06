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
    
    @AppStorage(StorageKeys.showAppIcons) private var showAppIcons = true
    @AppStorage(StorageKeys.showBundle) private var showBundle = false
    @AppStorage(StorageKeys.hideWarning) private var hideWarning = false
    
    @State private var searchText = ""
    @State private var showingAddAppSheet = false
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            HStack {
                VStack(alignment: .leading) {
                    Text("liquid_glass_deactivator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("v\(viewModel.appVersion())")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            
            
            Form {
                Section {
                    RedToggle(isOn: $viewModel.globalDisabled,
                              title: NSLocalizedString("disable_globally", comment: ""),
                              subtitle: String(localized: "restart_could_be_required"),
                              isLoading: viewModel.isLoading
                    )
                }
            }
            
            if (!hideWarning) {
                Form {
                    Section {
                        WarningView(title: "main_warning_title", hoverMessage: "main_warning_description")
                            .contextMenu {
                                Button("hide") {
                                    hideWarning = true;
                                }
                            }
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
                            showIcon: showAppIcons
                        )
                    }
                }
            }
        }
        .padding(.vertical)
        .frame(minWidth: 600, minHeight: 600)
        .sheet(isPresented: $showingAddAppSheet) {
            AddAppSheet(viewModel: viewModel)
        }
    }
    
}

