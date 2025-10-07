//
//  Warning.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 06/10/25.
//

import SwiftUI

struct WarningView: View {
    var title: String
    var hoverMessage: String
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var isLoading: Bool = false
    
    @State private var isHovering: Bool = false
    
    @AppStorage(StorageKeys.hideWarning) private var hideWarning = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.purple)
                
                ZStack(alignment: .leading) {
                    
                    Text(LocalizedStringKey(title))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .opacity(isHovering ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: isHovering)
                    
                    Text(LocalizedStringKey(hoverMessage))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .opacity(isHovering ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: isHovering)
                }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHovering = hovering
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple.opacity(0.1))
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                if !isLoading {
                    // nothing
                }
            }
            if (isHovering) {
                Text("right_click_to_hide")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2.5)
            }
        }
        .contextMenu {
            Button("hide") {
                hideWarning = true;
            }
        }
    }
}
