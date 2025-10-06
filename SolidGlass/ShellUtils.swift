//
//  ShellUtils.swift
//  SolidGlass
//
//  Created by Rafael Neuwirth Swierczynski on 05/10/25.
//

import Foundation

enum ShellUtils {
    @discardableResult
    static func runShellCommand(_ command: String) -> Int32 {
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        process.launch()
        process.waitUntilExit()
        return process.terminationStatus
    }
    
    static func runShellCommandWithOutput(_ command: String) -> String? {
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
        } catch {
            return nil
        }
        
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}
