//
//  MacApp.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 06/10/25.
//

import Foundation
import SwiftUI

struct MacApp: Identifiable {
    var id: String { bundleIdentifier ?? path.path }
    let name: String
    let bundleIdentifier: String?
    let path: URL
    let icon: NSImage?
    let warning: LocalizedStringKey?
}
