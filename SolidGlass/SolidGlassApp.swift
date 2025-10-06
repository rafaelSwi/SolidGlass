//
//  SolidGlassApp.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI

@main
struct SolidGlassApp: App {
    
    @State private var currentWindow: AppWindow = .main
    @StateObject private var appData = AppData()
    @StateObject private var viewModel: MainViewModel
    
    init() {
        let appData = AppData()
        _appData = StateObject(wrappedValue: appData)
        _viewModel = StateObject(wrappedValue: MainViewModel(appData: appData))
    }
    
    var body: some Scene {
        WindowGroup {
            
            switch currentWindow {
            case .main:
                MainView(currentWindow: $currentWindow, viewModel: viewModel)
                    .appDefaults()
                    .environmentObject(appData)
            case .settings:
                SettingsView(currentWindow: $currentWindow)
                    .appDefaults()
            case .donate:
                DonateView(currentWindow: $currentWindow)
                    .appDefaults()
                
                
            }
        }
    }
}
