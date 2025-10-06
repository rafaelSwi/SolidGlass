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
                
                // Remove o botão de fullscreen (verde)
                window.standardWindowButton(.zoomButton)?.isHidden = true
                
                // Permite apenas minimizar e fechar
                window.styleMask.remove(.resizable)
                window.styleMask.remove(.fullScreen)
                
                // Opcional: força tamanho fixo
                window.minSize = window.frame.size
                window.maxSize = window.frame.size
            })
    }
    
}

