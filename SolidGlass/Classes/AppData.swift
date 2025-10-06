//
//  AppData.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import Foundation
import Combine

class AppData: ObservableObject {
    @Published var apps: [InstalledApp] = []
}
