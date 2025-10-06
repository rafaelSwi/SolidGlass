//
//  DonateViewModel.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import SwiftUI
import Combine

@MainActor
final class DonateViewModel: ObservableObject {
    @Published var isBitcoin: Bool = true
    
    let btcAddress = "bc1qvluxh224489mt6svp23kr0u8y2upn009pa546t"
    let ltcAddress = "ltc1qz42uw4plam83f2sud2rckzewvdwm9vs4rfazl5"
    let email = "contatorafaelswi@gmail.com"
    
    var currentAddress: String { isBitcoin ? btcAddress : ltcAddress }
    var currentCoinSymbol: String { isBitcoin ? "bitcoinsign.circle.fill" : "l.circle.fill" }
    var currentColor: Color { isBitcoin ? .orange : Color("LTC") }
    var coinName: String { isBitcoin ? "BTC" : "LTC" }
    
    func toggleCoin() {
        isBitcoin.toggle()
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func getExplorerURL() -> URL? {
        if isBitcoin {
            return URL(string: "https://www.blockchain.com/explorer/addresses/btc/\(btcAddress)")
        } else {
            return URL(string: "https://litecoinspace.org/address/\(ltcAddress)")
        }
    }
}
