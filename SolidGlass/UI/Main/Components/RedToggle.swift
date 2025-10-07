//
//  RedToggle.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 06/10/25.
//

import SwiftUI

struct RedToggle: View {
    @Binding var isOn: Bool
    var title: String
    var subtitle: String
    var isLoading: Bool = false
    let onToggle: (Bool) -> Void
    
    @State private var isHoveringTitle: Bool = false

    var body: some View {
        HStack(spacing: 16) {

            HStack(spacing: 8) {
                ZStack(alignment: .leading) {

                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .opacity(isHoveringTitle ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: isHoveringTitle)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .opacity(isHoveringTitle ? 1 : 0)
                        .offset(x: 0)
                        .animation(.easeInOut(duration: 0.25), value: isHoveringTitle)
                }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHoveringTitle = hovering
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(isOn ? 0.3 : 0))
                    .frame(width: 60, height: 30)
                    .shadow(color: isOn ? Color.red.opacity(0.6) : .clear,
                            radius: 8, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.25), value: isOn)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(isOn ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .offset(x: isOn ? 15 : -15)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isOn ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isLoading {
                onToggle(!isOn)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isOn)
    }
}
