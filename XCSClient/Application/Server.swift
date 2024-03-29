//
//  Server.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum AuthenticationStrategy {
    case netrc
    case credentials(SecureCredentials)
}

struct Server {
    
    // MARK: - Types
    
    enum ServerError: Error {
        case executionError(code: Int)
        case jsonDecodingError(_ error: Error)
        case noResult
        case parameterError
        case credentialsRequired
    }
    
    // MARK: - Private instance variables
    
    private let xcodeServerAddress: String
    private let sshEndpoint: String
    private let netrcFilename: String
    
    private let curlToBot: String
    private let sshToBotArguments: [String]
    
    
    private let secureCopy = "/usr/bin/scp"
    
    private var apiUrl: String {
        return "https://\(xcodeServerAddress):20343/api"
    }
    private let defaultArguments: [String]
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init(
        xcodeServerAddress: String,
        sshEndpoint: String,
        netrcFilename: String
    ) {
        self.xcodeServerAddress = xcodeServerAddress
        self.sshEndpoint = sshEndpoint == "@" ? "": sshEndpoint
        decoder.dateDecodingStrategy = .formatted(DateFormatter.backendDate)
        self.netrcFilename = netrcFilename
        
        let defaultArgs: [String]
        if !sshEndpoint.isEmpty,
           sshEndpoint != "@" {
            curlToBot = "/usr/bin/ssh"
            defaultArgs = [sshEndpoint] + ["curl", "-k"]
            sshToBotArguments = [sshEndpoint, "/usr/bin/ssh"]
        } else {
            curlToBot = "/usr/bin/curl"
            defaultArgs = ["-k"]
            sshToBotArguments = [String]()
        }
        if !netrcFilename.isEmpty {
            defaultArguments = defaultArgs + ["--netrc-file", netrcFilename]
        } else {
            defaultArguments = defaultArgs
        }
    }
    
    // MARK: - Public interface
    
    var authenticatesWithNetRC: Bool {
        return !netrcFilename.isEmpty
    }
    
    func getBotList() -> Result<[Bot], Error> {
        let arguments = defaultArguments + ["--request", "GET", "\(apiUrl)/bots"]
        let rslt: Result<BotsQueryResponse, Error> = executeJSONTask(with: arguments)
        return rslt.map { $0.results }
    }
    
    func getIntegrations(for bot: String, last: Int?) -> Result<[Integration], Error> {
        let arguments: [String]
        if bot.isEmpty {
            arguments = defaultArguments + [
                "--request", "GET",
                "\(apiUrl)/integrations"
            ]
        } else {
            if let last = last {
                arguments = defaultArguments + [
                    "--request", "GET",
                    "\(apiUrl)/bots/\(bot)/integrations?last=\(last)"
                ]
            } else {
                arguments = defaultArguments + [
                    "--request", "GET",
                    "\(apiUrl)/bots/\(bot)/integrations"
                ]
            }
        }
        let rslt: Result<IntegrationsQueryResponse, Error> = executeJSONTask(with: arguments)
        return rslt.map { $0.results }
    }
    
    func getLatestResult(for bot: String, to targetUrl: URL) -> Result<Bool, Error> {
        let arguments = defaultArguments + ["--request", "GET", "\(apiUrl)/bots/\(bot)/integrations?last=1&summary_only=true"]
        let rslt: Result<IntegrationsQueryResponse, Error> = executeJSONTask(with: arguments)
        switch rslt {
        case .success(let integrationResult):
            if let first = integrationResult.results.first {
                return downloadAssets(for: first.id, to: targetUrl).map { _ in true }
            } else {
                return .failure(NSError(message: "Unable to get infoamtion for the last integration of bot \(bot)"))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func downloadAssets(for integrationId: String, to targetUrl: URL) -> Result<Bool, Error> {
        let newArguments = defaultArguments + ["\(apiUrl)/integrations/\(integrationId)/assets --output \(sshEndpoint.isEmpty ? targetUrl.path: "logResults.tgz")"]
        let rslt = execute(program: curlToBot, with: newArguments)
        switch rslt {
        case .success:
            if !sshEndpoint.isEmpty {
                let newRslt = execute(program: secureCopy, with: ["\(sshEndpoint):logResults.tgz", "\(targetUrl.path)"])
                
                // cleanup temp file
                if !sshEndpoint.isEmpty {
                    let rmArguments = [sshEndpoint, "rm", "logResults.tgz"]
                    _ = execute(program: "/usr/bin/ssh", with: rmArguments)
                }
                
                switch newRslt {
                case .success:
                    return .success(true)
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .success(true)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func downloadAsset(_ path: String, to targetUrl: URL) -> Result<Bool, Error> {
        let newArguments = defaultArguments + ["\(apiUrl)/assets/\(path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? path) --output \(sshEndpoint.isEmpty ? targetUrl.path: "tmpFile")"]
        let rslt = execute(program: curlToBot, with: newArguments)
        switch rslt {
        case .success:
            if !sshEndpoint.isEmpty {
                let newRslt = execute(program: secureCopy, with: ["\(sshEndpoint):tmpFile", "\(targetUrl.path)"])
                
                // cleanup temp file
                if !sshEndpoint.isEmpty {
                    let rmArguments = [sshEndpoint, "rm", "tmpFile"]
                    _ = execute(program: "/usr/bin/ssh", with: rmArguments)
                }
                
                switch newRslt {
                case .success:
                    return .success(true)
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .success(true)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func findIpaPath(machineName: String, botID: String, botName: String, integrationNumber: Int) -> String {
        // The API only allows us to download the whole Archive with all results:
        // xcarchive AND ipa.
        // That's often a pretty huge archive, when all we want is the ipa...
        
        // For now we use the hardcoded path to the default location here! :-(
        // TODO: Query the install path from the server OR make that a property of CDServer
        var directory = "\"/Library/Developer/XcodeServer/IntegrationAssets/\(botID)-\(botName)/\(integrationNumber)\""
        let ipaPath = findIpaInDirectory(machineName: machineName, fullPath: directory)
        guard ipaPath.isEmpty else {
            return ipaPath
        }
        // Not there...
        // So now we try the directory, where some after-trigger scripts
        // create the ipa to using the xcodebuild commandline tool from the xcarchive...
        let botNameWithoutSpaces = botName.replacingOccurrences(of: " ", with: "_")
        directory = "\"/Users/\(machineName)/XcodeServerBuilds/\(botNameWithoutSpaces)_\(integrationNumber)\""
        var customIpaPath = findIpaInDirectory(machineName: machineName, fullPath: directory)
        if customIpaPath.isEmpty {
            directory = "\"/Users/\(machineName)/Desktop/XcodeServerBuilds/\(botNameWithoutSpaces)_\(integrationNumber)\""
            customIpaPath = findIpaInDirectory(machineName: machineName, fullPath: directory)
            guard !customIpaPath.isEmpty else {
                return ""
            }
        }
        let comps = customIpaPath.components(separatedBy: "/").dropLast()
        return comps.joined(separator: "/")
    }
    
    func scpFromBot(_ absolutePath: String, to targetUrl: URL, machineName: String) -> Result<Bool, Error> {
        guard !isLocalServer else {
            let result = execute(program: "cp", with: ["-R", absolutePath, targetUrl.path])
            switch result {
            case .success:
                return .success(true)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        guard let userName = try? currentUserName(for: machineName, orFromPath: absolutePath) else {
            return .failure(ServerError.parameterError)
        }
        var rmArguments = ["\(userName)@\(xcodeServerAddress)", "rm", "tmp.zip"]
        var zipArguments = ["\(userName)@\(xcodeServerAddress)", "zip", "-r", "tmp.zip", absolutePath]
        if !sshEndpoint.isEmpty {
            zipArguments = [sshEndpoint, "/usr/bin/ssh"] + zipArguments
            rmArguments = [sshEndpoint, "/usr/bin/ssh"] + rmArguments
        }
        _ = execute(program: "/usr/bin/ssh", with: rmArguments)
        _ = execute(program: "/usr/bin/ssh", with: zipArguments)
        let scpAddress: String
        if !sshEndpoint.isEmpty {
            let r1 = execute(program: "/usr/bin/ssh", with: [sshEndpoint, secureCopy, "\(userName)@\(xcodeServerAddress):tmp.zip", "tmp.zip"])
            switch r1 {
            case .success(let data):
                print(String(decoding: data, as: UTF8.self))
            case .failure(let error):
                return .failure(error)
            }
            scpAddress = sshEndpoint
        } else {
            scpAddress = "\(userName)@\(xcodeServerAddress)"
        }
        let result = execute(program: secureCopy, with: ["\(scpAddress):tmp.zip", "\(targetUrl.path)"])
        
        // cleanup temp file
        if !sshEndpoint.isEmpty {
            let rmArguments = [sshEndpoint, "rm", "tmp.zip"]
            _ = execute(program: "/usr/bin/ssh", with: rmArguments)
        }
        
        switch result {
        case .success:
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func listOfAvailableSimulators(authenticationStrategy: AuthenticationStrategy) -> Result<String, Error> {
        guard let (username, password) = credentials(for: authenticationStrategy, skipNetRCParsing: false) else {
            return .failure(ServerError.credentialsRequired)
        }
        let program = isLocalServer ? "sudo": "/usr/bin/ssh"
        var xcsCommand = ["-S", "xcrun", "xcscontrol", "--list-simulators"]
        if !isLocalServer {
            xcsCommand = ["\(username)@\(xcodeServerAddress)", "sudo"] + xcsCommand
            if !sshEndpoint.isEmpty {
                xcsCommand = [sshEndpoint, "/usr/bin/ssh"] + xcsCommand
            }
        }
        let result = execute(program: program, with: xcsCommand, dataInput: (password + "\n").data(using: .utf8))
            .map { String(data: $0, encoding: .utf8) ?? "" }
        return result
    }
    
    func loadAsset(_ path: String) -> Result<Data, Error> {
        guard !path.isEmpty else {
            return .failure(ServerError.parameterError)
        }
        let newArguments = defaultArguments + ["\(apiUrl)/assets/\(path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? path)"]
        let rslt = execute(program: curlToBot, with: newArguments)
        switch rslt {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteBot(botId: String, revId: String) -> Result<Bool, Error> {
        let arguments = defaultArguments + [
            "--request", "DELETE",
            //            "-H", "\"X-XCSClientVersion: 7\"",
            "\(apiUrl)/bots/\(botId)/\(revId)"
        ]
        let rslt = execute(program: curlToBot, with: arguments)
        switch rslt {
        case .success(let data):
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                return .failure(NSError(message: errorResponse.message, status: errorResponse.status))
            }
            if data.isEmpty {
                return .success(true)
            } else {
                return .failure(NSError(message: String(data: data, encoding: .utf8) ?? String(describing: data)))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func duplicateBot(_ botId: String) -> Result<Bot, Error> {
        let arguments = defaultArguments + [
            "--request", "POST",
            "-d", "{}",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            //            "-H", "\"X-XCSClientVersion: 7\""
            "\(apiUrl)/bots/\(botId)/duplicate"
        ]
        return executeJSONTask(with: arguments)
    }
    
    func applySettings(at fileUrl: URL, fileName: String, toBot botId: String, authenticationStrategy: AuthenticationStrategy) -> Result<Bot, Error> {
        let rslt = copyBotSettingsToServer(fileUrl: fileUrl, fileName: fileName)
        switch rslt {
        case .success(let path):
            return self.modifyBot(botId, settingsFile: path, authenticationStrategy: authenticationStrategy)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createBot(fileUrl: URL, fileName: String) -> Result<Bot, Error> {
        let rslt = copyBotSettingsToServer(fileUrl: fileUrl, fileName: fileName)
        switch rslt {
        case .success(let path):
            let result = self.createBotWithSettings(settingsFile: path)
            removeFileOnHost(fileName: fileName)
            return result
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func integrate(_ botId: String) -> Result<Integration, Error> {
        let arguments = defaultArguments + [
            "--request", "POST",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "\(apiUrl)/bots/\(botId)/integrations"
        ]
        return executeJSONTask(with: arguments)
    }
    
    func cancelIntegration(_ integrationId: String) -> Result<Bool, Error> {
        let arguments = defaultArguments + [
            "--request", "POST",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "\(apiUrl)/integrations/\(integrationId)/cancel"
        ]
        return execute(program: curlToBot, with: arguments)
            .map { _ in true }
    }
    
    // MARK: - Private interface
    
    private var isLocalServer: Bool {
        if xcodeServerAddress.isEmpty {
            return true
        }
        return ["localhost", "127.0.0.1"].contains(xcodeServerAddress)
    }
    
    private func credentials(for strategy: AuthenticationStrategy, skipNetRCParsing: Bool = true) -> (String, String)? {
        switch strategy {
        case .netrc:
            guard !netrcFilename.isEmpty else {
                return nil
            }
            guard !skipNetRCParsing else {
                return ("", "")
            }
            guard let rslt = credentialsFromNetRCFile(netrcFilename, for: xcodeServerAddress) else {
                return nil
            }
            return rslt
        case .credentials(let credentials):
            guard let rslt = credentials.loginData else {
                return nil
            }
            return rslt
        }
    }
    
    private func credentialsFromNetRCFile(_ netrcFilename: String, for ipAddress: String) -> (String, String)? {
        let program = isLocalServer ? "cat": "/usr/bin/ssh"
        var args = [netrcFilename]
        if !isLocalServer,
           !sshEndpoint.isEmpty {
                args = [sshEndpoint, "cat"] + args
        }
        let result = execute(program: program, with: args)
            .map { String(data: $0, encoding: .utf8) ?? "" }
        switch result {
        case .success(let netrcContents):
            guard let line = netrcContents.components(separatedBy: "\n")
                    .filter({ !$0.trimmingCharacters(in: .whitespaces).starts(with: "#") })
                    .first(where: { $0.contains(ipAddress) }) else {
                return nil
            }
            let parts = line.components(separatedBy: .whitespaces)
            guard let machinePos = parts.firstIndex(of: "machine"),
                  parts.count > machinePos else {
                return nil
            }
            let machine = parts[machinePos + 1]
            guard let loginPos = parts.firstIndex(of: "login"),
                  parts.count > loginPos else {
                return nil
            }
            let login = parts[loginPos + 1]
            guard let passPos = parts.firstIndex(of: "password"),
                  parts.count > passPos else {
                return nil
            }
            let password = parts.dropFirst(passPos + 1).joined(separator: " ")
            guard machine == ipAddress else {
                return nil
            }
            return (login, password)
        case .failure:
            return nil
        }
    }
    
    /// Modify a bot using settings from a json file
    /// The file is expected to be at the rootlevel of the ssh user on the jumphost!
    private func modifyBot(_ botId: String, settingsFile: String, authenticationStrategy: AuthenticationStrategy) -> Result<Bot, Error> {
        guard let (username, secret) = credentials(for: authenticationStrategy, skipNetRCParsing: true) else {
            return .failure(ServerError.credentialsRequired)
        }
        var arguments = defaultArguments + [
            "--request", "PATCH",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "-H", "\"X-XCSClientVersion: 7\"",
            "--data", "\"@\(settingsFile)\""
        ]
        if !authenticatesWithNetRC {
            arguments.append("-u")
            arguments.append("\(username):\(secret)")
        }
        arguments.append("\(apiUrl)/bots/\(botId)?overwriteBlueprint=true")
        return executeJSONTask(with: arguments)
    }
    
    private func createBotWithSettings(settingsFile: String) -> Result<Bot, Error> {
        let arguments = defaultArguments + [
            "--request", "POST",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "--data", "\"@\(settingsFile)\"",
            "\(apiUrl)/bots"
        ]
        return executeJSONTask(with: arguments)
    }
    
    private func currentUserName(for machine: String, orFromPath absolutePath: String) throws -> String {
        guard machine.isEmpty else {
            return machine
        }
        let userNameAndPatch = getUsernameFrom(absolutePath: absolutePath)
        guard let uname = userNameAndPatch.username else {
            throw ServerError.parameterError
        }
        return uname
    }
    
    private func executeJSONTask<T: Decodable>(with arguments: [String]) -> Result<T, Error> {
        let rslt = execute(program: curlToBot, with: arguments)
        return rslt.flatMap { data in
            let rslt = Result { try decoder.decode(T.self, from: data) }
            return rslt
        }
    }
    
    private func execute(program: String, with arguments: [String], dataInput: Data? = nil) -> Result<Data, Error> {
        let task = Process()
        task.launchPath = program
        task.arguments = arguments
        
        // // comment out for debugging purposes:
        // print("executing now:\n\(program) \(arguments.joined(separator: " "))")
        
        if let dataInput = dataInput {
            let inPipe = Pipe()
            task.standardInput = inPipe
            let inHandle = inPipe.fileHandleForWriting
            inHandle.write(dataInput)
        }
        let outPipe = Pipe()
        task.standardOutput = outPipe // to capture standard error, use task.standardError = outPipe
        let errorPipe = Pipe()
        task.standardError = errorPipe
        task.launch()
        let fileHandle = outPipe.fileHandleForReading
        let data = fileHandle.readDataToEndOfFile()
        let errorHandle = errorPipe.fileHandleForReading
        let errorData = errorHandle.readDataToEndOfFile()
        task.waitUntilExit()
        let status = task.terminationStatus
        if status != 0 {
            return .failure(NSError(jumpHostError: errorData, status: Int(status)))
        } else {
            if let error = try? decoder.decode(ErrorResponse.self, from: data) {
                return .failure(NSError(message: error.message, status: error.status))
            }
            // print(String(decoding: data, as: UTF8.self))
            return .success(data)
        }
    }
    
    private func getUsernameFrom(absolutePath: String) -> (username: String?, remainingPath: String) {
        var pathComps = absolutePath.components(separatedBy: "/")
        guard let root = pathComps.first,
              root == "" else {
            return (username: nil, remainingPath: absolutePath)
        }
        pathComps.remove(at: 0)
        guard let users = pathComps.first,
              users == "Users" else {
            return (username: nil, remainingPath: absolutePath)
        }
        pathComps.remove(at: 0)
        guard let machine = pathComps.first,
              !machine.isEmpty else {
            return (username: nil, remainingPath: absolutePath)
        }
        pathComps.remove(at: 0)
        return (username: machine, remainingPath: pathComps.joined(separator: "/"))
    }
    
    private func findIpaInDirectory(machineName: String, fullPath: String) -> String {
        let program = isLocalServer ? "find": "/usr/bin/ssh"
        let cmd = isLocalServer ? [String](): ["\(machineName)@\(xcodeServerAddress)", "find"]
        let args = sshToBotArguments + cmd + [fullPath, "-name", "\"*.ipa\""]
        let result = execute(program: program, with: args)
        switch result {
        case .success(let data):
            let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return str ?? ""
        case.failure:
            return ""
        }
    }
    
    private func removeFileOnHost(fileName: String) {
        let program: String
        let args: [String]
        if !sshEndpoint.isEmpty,
           sshEndpoint != "@" {
            program = "/usr/bin/ssh"
            args = [sshEndpoint, "rm", fileName]
        } else {
            program = "rm"
            args = [fileName]
        }
        _ = execute(program: program, with: args)
    }
    
    private func copyBotSettingsToServer(fileUrl: URL, fileName: String) -> Result<String, Error> {
        guard !sshEndpoint.isEmpty else {
            return .success(fileUrl.path)
        }
        let rslt = execute(program: secureCopy, with: ["\(fileUrl.path)", "\(sshEndpoint):\(fileName)"])
        switch rslt {
        case .success:
            return .success(fileName)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension DateFormatter {
    static let backendDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static let buildLogDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM dd hh:mm:ss"
        formatter.calendar = Calendar.current
        return formatter
    }()
}
