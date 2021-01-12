//
//  CreateNewBotForm.swift
//  XCSClient
//
//  Created by Alex da Franca on 11.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct CreateNewBotForm: View {
    var server: CDServer?
    @Binding var isShowing: Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var scmKey = ""
    @State private var project = ""
    @State private var repoUrl = ""
    @State private var branchName = ""
    @State private var repoPath = ""
    @State private var repoUser = ""
    @State private var repoPass = ""
    
    @State private var activityShowing = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create new Bot")
                    .font(.title)
                LabeledTextInput(label: "Name", content: $name)
                LabeledTextInput(label: "Scm Key", content: $scmKey)
                LabeledTextInput(label: "Relative Path to project or workspace", content: $project)
                LabeledTextInput(label: "Repository URL", content: $repoUrl)
                LabeledTextInput(label: "Branch", content: $branchName)
                LabeledTextInput(label: "Repository path", content: $repoPath)
                LabeledTextInput(label: "Repository username", content: $repoUser)
                LabeledTextInput(label: "Repository password", content: $repoPass)
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Text("Cancel")
                    }
                    Button(action: createNewBot) {
                        Text("Create")
                    }
                }
            }
            .padding()
            .background(Color("LightBackground"))
            .cornerRadius(8)
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .padding()
            
            if activityShowing {
                Color.black
                    .opacity(0.5)
                VStack {
                    ActivityIndicator()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Text("Loading…")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func createNewBot() {
        createBot(
            name: name,
            scmKey: scmKey,
            project: project,
            repoUrl: repoUrl,
            branchName: branchName,
            repoPath: repoPath,
            repoUser: repoUser,
            repoPass: repoPass
        )
    }
    
    private func createBot(
        name: String,
        scmKey: String,
        project: String,
        repoUrl: String,
        branchName: String,
        repoPath: String,
        repoUser: String,
        repoPass: String
    ) {
        
        let sourceControlBlueprint = SourceControlBlueprint.standard(scmKey: scmKey, branchName: branchName, project: project, repoUrl: repoUrl, repoPath: repoPath, repoUser: repoUser, repoPass: repoPass)
        
        let config = BotConfiguration.standard(
            scheme: "DHLPaket_Git",
            sourceControlBlueprint: sourceControlBlueprint
        )
        let newBot = Bot.standard(name: name, configuration: config)
        
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let tempFileUrl = cachesDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        do {
            try Data(newBot.asBodyParamater.utf8).write(to: tempFileUrl)
            
            withAnimation {
                self.activityShowing = true
            }
            server?.connector.createBot(fileUrl: tempFileUrl, fileName: "tmp.json") { result in
                switch result {
                case .success(let bot):
                    server?.reachability = Int16(ServerReachabilty.reachable.rawValue)
                    if let bot = viewContext.bot(from: bot) {
                        server?.addToItems(bot)
                    }
                    saveContext()
                case .failure(let error):
                    print("Error creating bot: \(error.localizedDescription)")
                    server?.reachability = Int16(ServerReachabilty.unreachable.rawValue)
                }
                withAnimation {
                    isShowing = false
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CreateNewBotForm_Previews: PreviewProvider {
    @State private static var createNewBotFormShowing = true
    static var previews: some View {
        CreateNewBotForm(isShowing: $createNewBotFormShowing)
            
    }
}
