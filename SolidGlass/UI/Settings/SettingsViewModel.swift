//
//  SettingsViewModel.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var checkingUpdate = false
    @Published var updateAvailable = false
    @Published var latestVersion: String = ""
    @Published var releaseURL: URL? = nil
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    private func isVersion(_ v1: String, olderThan v2: String) -> Bool {
        let v1Components = v1.split(separator: ".").compactMap { Int($0) }
        let v2Components = v2.split(separator: ".").compactMap { Int($0) }
        for (a, b) in zip(v1Components, v2Components) {
            if a < b { return true }
            if a > b { return false }
        }
        return v1Components.count < v2Components.count
    }
    
    func checkForUpdate() {
        checkingUpdate = true
        updateAvailable = false
        latestVersion = ""
        releaseURL = nil
        
        guard let url = URL(string: "https://api.github.com/repos/rafaelSwi/SolidGlass/releases/latest") else {
            checkingUpdate = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.checkingUpdate = false
                }
                return
            }
            
            if let release = try? JSONDecoder().decode(GitHubRelease.self, from: data) {
                let latest = release.tag_name.replacingOccurrences(of: "v", with: "")
                let releaseURL = URL(string: release.html_url)
                let updateAvailable = self.isVersion(self.appVersion, olderThan: latest)
                
                DispatchQueue.main.async {
                    self.latestVersion = latest
                    self.releaseURL = releaseURL
                    self.updateAvailable = updateAvailable
                    self.checkingUpdate = false
                    
                    if let sound = NSSound(named: NSSound.Name(updateAvailable ? "Submarine" : "Glass")) {
                        sound.play()
                    }
                }
            } else {
                DispatchQueue.main.async { self.checkingUpdate = false }
            }
        }.resume()
    }
    
}
