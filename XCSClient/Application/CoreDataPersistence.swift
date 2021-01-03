//
//  Persistence.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.12.20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "XCSClient")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

// Dummy Data for Previews

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        var bot = Bot(id: "123", name: "Project_Foo_Fabric_DeviceCloud", tinyID: "3")
        var configuration = BotConfiguration()
        configuration.performsArchiveAction = true
        configuration.buildEnvironmentVariables = ["EINS": "zwei", "DREI": "vier"]
        configuration.archiveExportOptions = ArchiveExportOptions(name: "ExportOptions", createdAt: Date(), exportOptions: nil)
        bot.configuration = configuration
        bot.integrationCounter = 12
        
        let cdBot = CDBot(context: viewContext)
        cdBot.update(with: bot)
        
        let logfile = LogFile(allowAnonymousAccess: true, fileName: "Source Control Logs", isDirectory: false, relativePath: "NotEmpty", size: 3474)
        let logfile2 = LogFile(allowAnonymousAccess: true, fileName: "Archive", isDirectory: false, relativePath: "NotEmpty", size: 143456474)
        let logfile3 = LogFile(allowAnonymousAccess: true, fileName: "A very very long name", isDirectory: false, relativePath: "NotEmpty", size: 34536474)
        
        let assets = IntegrationAssets(archive: logfile, buildServiceLog: logfile2, sourceControlLog: logfile3, xcodebuildLog: logfile2, xcodebuildOutput: logfile, triggerAssets: [logfile3])
        
        let integration = Integration(id: "345", rev: "", assets: assets, bot: nil, buildResultSummary: BuildResultSummary(analyzerWarningChange: -3, analyzerWarningCount: 0, codeCoveragePercentage: 48, codeCoveragePercentageDelta: 5, errorChange: 0, errorCount: 0, improvedPerfTestCount: 0, regressedPerfTestCount: 0, testFailureChange: 1, testFailureCount: 2, testsChange: 0, testsCount: 80, warningChange: 0, warningCount: 10), buildServiceFingerprint: "", ccPercentage: 0, ccPercentageDelta: 0, currentStep: "completed", docType: "", duration: 230, endedTime: Date(), number: 1, queuedDate: nil, result: IntegrationResult.buildErrors, revisionBlueprint: nil, startedTime: Date().advanced(by: 120), testHierarchy: nil, testedDevices: nil, tinyID: "1817142698624")
        
        let cdIntegration = CDIntegration(context: viewContext)
        cdIntegration.update(with: integration)
        cdBot.addToItems(cdIntegration)
        
        let cdServer = CDServer(context: viewContext)
        cdServer.id = "678"
        cdServer.ipAddress = "192.168.1.2"
        cdServer.name = "Test Server"
        cdServer.netRCFilename = ".hidden"
        cdServer.sshAddress = "10.11.12.1"
        cdServer.sshUser = "alex"
        
        cdServer.addToItems(cdBot)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
