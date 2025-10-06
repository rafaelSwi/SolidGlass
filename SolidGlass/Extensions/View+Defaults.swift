//
//  View+Defaults.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func appDefaults() -> some View {
        self
            .background(WindowConfigurator { window in
                guard let window = window else { return }
                
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.styleMask.remove(.resizable)
                window.styleMask.remove(.fullScreen)
                window.minSize = window.frame.size
                window.maxSize = window.frame.size
            })
            .preferredColorScheme(.dark)
    }
    
}

