//
//  IntegrationResultsIconView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.01.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct IntegrationResultsIconView: View {
        let integration: IntegrationViewModel
        
        var body: some View {
            HStack(alignment: .top) {
                Spacer()
                VStack {
                    Text("🐞")
                        .font(.largeTitle)
                    Text("\(integration.errorCount) Errors")
                        .font(.headline)
                    Text("(\(integration.errorChange))")
                }
                Spacer()
                VStack {
                    Text("⚠️")
                        .font(.largeTitle)
                    Text("\(integration.warningCount) Warnings")
                        .font(.headline)
                    Text("(\(integration.warningChange))")
                }
                Spacer()
                VStack {
                    Text("🛠")
                        .font(.largeTitle)
                    Text("\(integration.analyzerWarnings) Issues")
                        .font(.headline)
                    Text("(\(integration.analyzerWarningChange))")
                }
                Spacer()
                VStack {
                    Text(integration.testFailureCount > 0 ? "❌": "✅")
                        .font(.largeTitle)
                    Text("Passed/Failed tests: \(integration.passedTestsCount)/\(integration.testFailureCount)")
                        .font(.headline)
                    Text("(\(integration.passedTestsChange)/\(integration.testFailureChange))")
                }
                Spacer()
            }
        }
}

struct IntegrationResultsIconView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext
        let request: NSFetchRequest<CDIntegration> = CDIntegration.fetchRequest()
        let obj = (try? moc.fetch(request).first)!
        IntegrationResultsIconView(integration: obj)
    }
}
