//
//  DonateView.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct DonateView: View {
    
    @Environment(\.openURL) var openURL
    @Binding var currentWindow: AppWindow
    @StateObject private var viewModel = DonateViewModel()
    
    struct QRCodeView: View {
        let text: String
        
        var body: some View {
            if let image = generateQRCode(from: text) {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            } else {
                Color.gray.frame(width: 250, height: 250)
            }
        }
        
        private func generateQRCode(from string: String) -> NSImage? {
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()
            filter.message = Data(string.utf8)
            
            guard let outputImage = filter.outputImage else { return nil }
            
            let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
            
            if let cgimg = context.createCGImage(scaled, from: scaled.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: 300, height: 300))
            }
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("donate_description")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            QRCodeView(text: viewModel.currentAddress)
                .contextMenu {
                    Button {
                        if let url = viewModel.getExplorerURL() {
                            openURL(url)
                        }
                    } label: {
                        Label("check_on_blockchain", systemImage: "globe")
                    }
                    
                    Button { viewModel.copyToClipboard(viewModel.currentAddress) } label: {
                        Label("copy_crypto_address", systemImage: "square.on.square")
                    }
                    
                    Button { viewModel.copyToClipboard(viewModel.email) } label: {
                        Label("copy_email", systemImage: "square.on.square")
                    }
                }
            
            VStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: viewModel.currentCoinSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(viewModel.currentColor)
                    Text(viewModel.isBitcoin ? "bitcoin_on_chain_transfer" : "litecoin_on_chain_transfer")
                        .font(.callout)
                        .bold()
                }
                
                Text(viewModel.currentAddress)
                    .contextMenu {
                        Button { viewModel.copyToClipboard(viewModel.currentAddress) } label: {
                            Label("copy", systemImage: "square.on.square")
                        }
                    }
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal)
                
                Text(String(format: NSLocalizedString("contact", comment: "EMAIL"), viewModel.email))
                    .contextMenu {
                        Button { viewModel.copyToClipboard(viewModel.email) } label: {
                            Label("copy_email", systemImage: "square.on.square")
                        }
                    }
                    .font(.footnote)
            }
            
            Button(action: { viewModel.toggleCoin() }) {
                Text(viewModel.isBitcoin ? "show_ltc_address" : "show_btc_address")
            }
            .padding(.top)
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: { currentWindow = .settings }) {
                    Label("back", systemImage: "arrow.uturn.backward")
                }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 600)
    }
}
