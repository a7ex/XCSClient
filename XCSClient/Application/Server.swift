//
//  Server.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 05.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Server {
    enum ServerError: Error {
        case executionError(code: Int)
        case jsonDecodingError(_ error: Error)
        case noResult
    }
    
    private let sshEndpoint: String // = "adafranca@10.175.31.236"
    private let xcodeServerAddress: String // "10.172.200.20"
    
    private let sshClient = "/usr/bin/ssh"
    private let secureCopy = "/usr/bin/scp"
    private var apiUrl: String {
        return "https://\(xcodeServerAddress):20343/api"
    }
    private var defaultArguments: [String] {
        [sshEndpoint, "curl", "-k", "--netrc-file", ".xcbot"]
    }
    private let decoder = JSONDecoder()
    
    init(xcodeServerAddress: String, sshEndpoint: String) {
        self.xcodeServerAddress = xcodeServerAddress
        self.sshEndpoint = sshEndpoint
        decoder.dateDecodingStrategy = .formatted(DateFormatter.backendDate)
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
                "-H", "\"X-XCSClientVersion: 7\"",
                "\(apiUrl)/integrations"
            ]
        } else {
            if let last = last {
                arguments = defaultArguments + [
                    "--request", "GET",
                    "-H", "\"X-XCSClientVersion: 7\"",
                    "\(apiUrl)/bots/\(bot)/integrations?last=\(last)"
                ]
            } else {
                arguments = defaultArguments + [
                    "--request", "GET",
                    "-H", "\"X-XCSClientVersion: 7\"",
                    "\(apiUrl)/bots/\(bot)/integrations"
                ]
            }
        }
        let rslt: Result<IntegrationsQueryResponse, Error> = executeJSONTask(with: arguments)
        return rslt.map { $0.results }
    }
    
    func getLatestResult(for bot: String) -> Result<Bool, Error> {
        let arguments = defaultArguments + ["--request", "GET", "\(apiUrl)/bots/\(bot)/integrations?last=1&summary_only=true"]
        let rslt: Result<IntegrationsQueryResponse, Error> = executeJSONTask(with: arguments)
        switch rslt {
        case .success(let integrationResult):
            if let first = integrationResult.results.first {
                return downloadAssets(for: first.tinyID ?? "").map { _ in true }
            } else {
                return .failure(NSError(message: "Unable to get infoamtion for the last integration of bot \(bot)"))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func downloadAssets(for integrationId: String) -> Result<Bool, Error> {
        let newArguments = defaultArguments + ["\(apiUrl)/integrations/\(integrationId)/assets --output logResults.tgz"]
        let rslt = execute(program: sshClient, with: newArguments)
        switch rslt {
        case .success:
            let newRslt = execute(program: secureCopy, with: ["adafranca@10.175.31.236:logResults.tgz", "logResults.tgz"])
            switch newRslt {
            case .success:
                return .success(true)
            case .failure(let error):
                return .failure(error)
            }
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
        let rslt = execute(program: sshClient, with: arguments)
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
    
    func modifyBot(_ botId: String, settingsFile: String) -> Result<Bot, Error> {
        let arguments = defaultArguments + [
            "--request", "PATCH",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "--data", "\"@\(settingsFile)\"",
            "\(apiUrl)/bots/\(botId)?overwriteBlueprint=true"
        ]
        return executeJSONTask(with: arguments)
    }
    
    func createBot(_ botJSON: String) -> Result<Bot, Error> {
        let arguments = defaultArguments + [
            "--request", "POST",
            "-H", "\"Content-Type: application/json; charset=utf-8\"",
            "--data", "\"@\(botJSON)\"",
            "\(apiUrl)/bots"
        ]
        return executeJSONTask(with: arguments)
    }
    
    func copyBotSettingsToServer(_ botId: String) -> Result<Bool, Error> {
        let fileName = "\(botId).json"
        let rslt = execute(program: secureCopy, with: [fileName, "\(sshEndpoint):\(fileName)"])
        switch rslt {
        case .success:
            return .success(true)
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
        return execute(program: sshClient, with: arguments)
            .map { _ in true }
    }
    
    // MARK: - Private
    
    private func executeJSONTask<T: Codable>(with arguments: [String]) -> Result<T, Error> {
        let rslt = execute(program: sshClient, with: arguments)
        return rslt.flatMap { data in
            try? data.write(to: URL(fileURLWithPath: "/Users/alex/Desktop/intgerations.json"))
            let rslt = Result { try decoder.decode(T.self, from: data) }
            return rslt
        }
    }
    
    func testCLI() {
        if let url = Bundle.main.url(forResource: "xcodeserverclient", withExtension: nil) {
        
            let rslt = execute(program: url.path, with: ["botlist"])
        switch rslt {
        case .success(let data):
            print(String(decoding: data, as: UTF8.self))
        case .failure(let error):
            print(error.localizedDescription)
        }
        } else {
            print("xcodeserverclient not found")
        }
    }
    
    private func execute(program: String, with arguments: [String]) -> Result<Data, Error> {
        let task = Process()
        task.launchPath = program
        task.arguments = arguments
        
//        print("executing now:\n\(program) \(arguments.joined(separator: " "))")
        
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
            return .failure(NSError(message: String(data: errorData, encoding: .utf8) ?? "Unknown", status: Int(status)))
        } else {
            if let error = try? decoder.decode(ErrorResponse.self, from: data) {
                return .failure(NSError(message: error.message, status: error.status))
            }
            return .success(data)
        }
    }
}

extension DateFormatter {
    static let backendDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
}
