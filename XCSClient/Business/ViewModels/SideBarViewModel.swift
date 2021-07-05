//
//  SideBarViewModel.swift
//  XCSClient
//
//  Created by Alex da Franca on 17.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation
import CoreData

struct SideBarViewModel {
    
    let masterColumnTitle = "Xcode Servers"
    let addServerButtonTitle = "Add server"
    
    func refreshAllServers(in ctx: NSManagedObjectContext) {
        DataSyncWorker.updateData(in: ctx)
    }
    
    func addServer(in ctx: NSManagedObjectContext, server: XcodeServer? = nil) {
        let srv = CDServer(context: ctx)
        srv.name = server?.name ?? "Local"
        srv.ipAddress = server?.ipAddress ?? "127.0.0.1"
        srv.id = UUID().uuidString
        srv.sshAddress = server?.sshAddress
        srv.sshUser = server?.sshUser
        srv.netRCFilename = server?.netRCFilename
        do {
            try ctx.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func migrateServersFromPreviousVersionIfNeccessary(in ctx: NSManagedObjectContext) {
        if numberOfServers(in: ctx) < 1 {
            // the previous version stored the infos about the servers
            // in the UserDefaults. This version stores them in CoreData
            if let dictionary = UserDefaults.standard.object(forKey: "xcodeServers") as? [[String: String]] ,
               let data = try? PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0),
               let servers = try? PropertyListDecoder().decode([XcodeServer].self, from: data) {
                if servers.isEmpty {
                    addServer(in: ctx)
                } else {
                    servers.forEach { addServer(in: ctx, server: $0) }
                }
                UserDefaults.standard.removeObject(forKey: "xcodeServers")
            } else {
                addServer(in: ctx)
            }
        }
    }
    
    private func numberOfServers(in ctx: NSManagedObjectContext) -> Int {
        let request: NSFetchRequest<CDServer> = CDServer.fetchRequest()
        do {
            let servers = try ctx.fetch(request)
            return servers.count
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
}
