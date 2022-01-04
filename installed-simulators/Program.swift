//
//  main.swift
//  installed-simulators
//
//  Created by Casey Liss on 4/1/22.
//

import Foundation

@main struct Main {
    static func main() async {
        let arguments = [
            "simctl",
            "list",
            "devices",
            "available"
        ]
        
        do {
            let rawList = try await run(command: URL(fileURLWithPath: "/usr/bin/xcrun"), arguments: arguments)
            let list = process(list: rawList)
            let e = generateEnum(from: list)
            if let data = e.data(using: .utf8) {
                let url = URL(fileURLWithPath: "./Simulator.swift")
                try data.write(to: url)
                print("Wrote to \(url.absoluteString)")
            }
        } catch RunCommandErrors.noDataReturned {
            print("No data was returned from the external command")
        } catch RunCommandErrors.commandError(let error) {
            print("An error was returned from the external command:")
            print("")
            print(error)
        } catch let RunCommandErrors.couldNotReadFromPipe(named, error) {
            print("Could not read from the \(named) pipe: \n\(error)")
        } catch {
            print("Unknown error:\n\(error)")
        }
    }
    
    // https://stackoverflow.com/a/67846989/98199
    static func run(command: URL, arguments: [String] = []) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            task.executableURL = command
            task.arguments = arguments
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            
            task.terminationHandler = { process in
                do {
                    let output = try string(from: outputPipe, named: "output")
                    let error = try string(from: errorPipe, named: "error")
                    
                    if let error = error, !error.isEmpty {
                        continuation.resume(throwing: RunCommandErrors.commandError(error))
                    } else if let output = output {
                        continuation.resume(returning: output)
                    } else {
                        continuation.resume(throwing: RunCommandErrors.noDataReturned)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            do {
                try task.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    static func string(from pipe: Pipe, named: String) throws -> String? {
        do {
            if let data = try pipe.fileHandleForReading.readToEnd() {
                return String(data: data, encoding: .utf8)
            } else {
                return nil
            }
        } catch {
            print("Could not read from \(named) pipe:\n\(error)")
            throw RunCommandErrors.couldNotReadFromPipe(named: named, error: error)
        }
    }

    enum RunCommandErrors: LocalizedError {
        case couldNotReadFromPipe(named: String, error: Error)
        case commandError(String)
        case noDataReturned
        case runError(Error)
    }
    
    static func process(list: String) -> [String] {
        let lines = list.split(separator: "\n")
        let simulators = lines.filter { $0.starts(with: "    ") }
        let retVal = simulators.compactMap { sim -> String? in
            // Find the simulator's UUID in the output
            guard let range = sim.range(of: #" \(([A-F]|\d|-)*\)"#, options: .regularExpression) else { return nil }
            // We want everything from the start index → GUID, less the leading/trailing whitespace.
            return sim[sim.startIndex...range.lowerBound].trimmingCharacters(in: .whitespaces)
        }
        return retVal//.map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    static func generateEnum(from list: [String]) -> String {
        var retVal =
        """
        import SwiftUI
        
        enum Simulator {
        
        """
        list.forEach { simulator in
            let name = simulator
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: "-", with: "")
            retVal += "\tstatic var \(name): PreviewDevice { PreviewDevice(rawValue: \"\(simulator)\") }\n"
        }
        retVal += "}\n"
        return retVal
    }
    
}
