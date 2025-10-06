//
//  InstalledApp.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import Foundation
import SwiftUI
import AppKit

struct InstalledApp {
    let name: String
    let bundleIdentifier: String?
    let path: URL
    let icon: NSImage?
    let warning: LocalizedStringKey?
}
