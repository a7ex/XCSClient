//
//  CDIntegrationView.swift
//  XCSClient
//
//  Created by Alex da Franca on 25.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import SwiftUI

struct CDIntegrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var fetchRequest: FetchRequest<CDIntegration>
    
    var integration: CDIntegration? {
        return fetchRequest.wrappedValue.first
    }
    
    init(integrationID: String) {
        fetchRequest = FetchRequest<CDIntegration>(
            entity: CDIntegration.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "id == %@", integrationID)
        )
    }
    
    var body: some View {
        if let integration = integration {
            IntegrationDetailView(integration: integration)
        } else {
            Text("No data")
        }
    }
}

struct CDIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        CDIntegrationView(integrationID: "")
    }
}
