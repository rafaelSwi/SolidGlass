//
//  FlagType.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth on 21/10/25.
//

enum FlagType: String, CaseIterable {
    case ignoreSolariumOptOut = "IgnoreSolariumOptOut";
    case ignoreSolariumHardwareCheck = "IgnoreSolariumHardwareCheck";
    case failSolariumHardwareCheck = "FailSolariumHardwareCheck";
    case ignoreSolariumLinkedOnCheck = "IgnoreSolariumLinkedOnCheck"; // force liquid glass
    
    // Deprecated Flags
    case disableSolarium = "DisableSolarium";
}
