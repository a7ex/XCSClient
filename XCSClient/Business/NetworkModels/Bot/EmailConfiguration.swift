//
//  EmailConfiguration.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct EmailConfiguration: Codable {
    var additionalRecipients: [String]?
    var allowedDomainNames: [String]?
    var ccAddresses: [String]?
    var emailCommitters: Bool?
    var fromAddress: String?
    var hour: Int?
    var includeBotConfiguration: Bool?
    var includeCommitMessages: Bool?
    var includeIssueDetails: Bool?
    var includeLogs: Bool?
    var includeResolvedIssues: Bool?
    var minutesAfterHour: Int?
    var replyToAddress: String?
    var scmOptions: [String: Int]?
    var type: Int?
    var weeklyScheduleDay: Int?
}

