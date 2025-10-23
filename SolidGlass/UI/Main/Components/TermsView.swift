//
//  TermsView.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth on 21/10/25.
//

import SwiftUI

struct TermsView: View {
    let title: String
    let message: String
    let agreeTitle: String
    let disagreeTitle: String
    let onAgree: () -> Void
    let onDisagree: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            ScrollView {
                Text(message)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
            }

            Divider()

            HStack(spacing: 16) {
                Button(action: onDisagree) {
                    Text(disagreeTitle)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                Button(action: onAgree) {
                    Text(agreeTitle)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: 500, maxHeight: 600)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 8)
        )
        .padding()
    }
}
