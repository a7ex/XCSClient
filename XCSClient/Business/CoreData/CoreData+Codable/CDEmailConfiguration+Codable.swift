//
//  CDEmailConfiguration+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 28.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDEmailConfiguration {
    func update(with configuration: EmailConfiguration) {
        additionalRecipients = configuration.additionalRecipients
        allowedDomainNames = configuration.allowedDomainNames
        ccAddresses = configuration.ccAddresses
        emailCommitters = configuration.emailCommitters ?? false
        fromAddress = configuration.fromAddress
        hour = Int16(configuration.hour ?? 0)
        includeBotConfiguration = configuration.includeBotConfiguration ?? false
        includeCommitMessages = configuration.includeCommitMessages ?? false
        includeIssueDetails = configuration.includeIssueDetails ?? false
        includeLogs = configuration.includeLogs ?? false
        includeResolvedIssues = configuration.includeResolvedIssues ?? false
        minutesAfterHour = Int16(configuration.minutesAfterHour ?? 0)
        replyToAddress = configuration.replyToAddress
        scmOptions = configuration.scmOptions
        type = Int64(configuration.type ?? 0)
        weeklyScheduleDay = Int16(configuration.weeklyScheduleDay ?? 0)
    }
}

extension CDEmailConfiguration {
    var asCodableObject: EmailConfiguration {
        return EmailConfiguration(
            additionalRecipients: additionalRecipients,
            allowedDomainNames: allowedDomainNames,
            ccAddresses: ccAddresses,
            emailCommitters: emailCommitters,
            fromAddress: fromAddress,
            hour: Int(hour),
            includeBotConfiguration: includeBotConfiguration,
            includeCommitMessages: includeCommitMessages,
            includeIssueDetails: includeIssueDetails,
            includeLogs: includeLogs,
            includeResolvedIssues: includeResolvedIssues,
            minutesAfterHour: Int(minutesAfterHour),
            replyToAddress: replyToAddress,
            scmOptions: scmOptions,
            type: Int(type),
            weeklyScheduleDay: Int(weeklyScheduleDay)
        )
    }
}
