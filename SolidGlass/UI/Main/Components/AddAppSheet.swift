//
//  AddAppSheet.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI
import AppKit
internal import UniformTypeIdentifiers

struct AddAppSheet: View {
    
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var bundleIDText = ""
    @State private var draggedURL: URL? = nil
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Text("add_app")
                .font(.title)
                .bold()
            
            TextField("bundle_identifier", text: $bundleIDText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(height: 100)
                
                Text(draggedURL != nil ? draggedURL!.lastPathComponent : String(localized: "drag_app_here"))
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                if let provider = providers.first {
                    _ = provider.loadObject(ofClass: URL.self) { object, error in
                        DispatchQueue.main.async {
                            if let url = object, url.pathExtension == "app" {
                                draggedURL = url
                                addApp(from: url)
                            }
                        }
                    }
                    return true
                }
                return false
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            HStack {
                Button("cancel") {
                    dismiss()
                }
                Spacer()
                Button("add") {
                    if !bundleIDText.isEmpty {
                        addApp(fromBundleID: bundleIDText)
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private func addApp(from url: URL) {
        if let bundle = Bundle(url: url) {
            let appName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                          bundle.infoDictionary?["CFBundleName"] as? String ??
                          url.deletingPathExtension().lastPathComponent
            let app = InstalledApp(name: appName, bundleIdentifier: bundle.bundleIdentifier, path: url, icon: NSImage(named: "unknown"), warning: "warning_external_app")
            
            if !viewModel.appData.apps.contains(where: { $0.path == url }) {
                viewModel.appData.apps.append(app)
            }
            dismiss()
        } else {
            errorMessage = "invalid_app_bundle"
        }
    }
    
    private func addApp(fromBundleID bundleID: String) {
        if let urls = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?.takeRetainedValue() as? [URL], let url = urls.first {
            addApp(from: url)
        } else {
            errorMessage = "app_not_found_for_bundle"
        }
    }
}
