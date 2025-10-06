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
    
    @State private var searchText = ""
    
    @State private var showingAddAppSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text("liquid_glass_deactivator")
                    .font(.title)
                    .bold()
                
                Text("v\(viewModel.appVersion())")
                    .font(.footnote)
                
                Spacer()
                
                Button(action: { currentWindow = .settings }) {
                    Label("settings", systemImage: "gear")
                }
                
                Button(action: { showingAddAppSheet.toggle() }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            
            HStack {
                Toggle(isOn: Binding(
                    get: { viewModel.globalDisabled },
                    set: { newValue in
                        viewModel.toggleGlobalSolarium(deactivate: newValue)
                    }
                )) {
                    Text("disable_globally")
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .disabled(viewModel.isLoading)
                .padding()
                
                Spacer()
            }
            
            TextField("search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Spacer()
                .frame(height: 20)
            
            if viewModel.isLoading {
                ProgressView("loading")
                    .padding()
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
        .padding()
        .frame(minWidth: 600, minHeight: 600)
        .sheet(isPresented: $showingAddAppSheet) {
            AddAppSheet(viewModel: viewModel)
        }
    }
}
