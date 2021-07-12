//
//  DeviceSheetView.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import SwiftUI

struct DeviceSheetView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CDTestDevice>
    var testDevices: FetchedResults<CDTestDevice> {
        return fetchRequest.wrappedValue
    }
    let refreshDeviceListCall: () -> Void
    let completion: ([String: String]) -> Void
    
    @Binding private var activityShowing: Bool
    @State private var selectionKeeper = Set<String>()
    private let initialIds: [String]
    
    init(
        deviceIDs: [String],
        serverID: String,
        isLoading: Binding<Bool>,
        refreshDeviceListCall: @escaping () -> Void,
        completion: @escaping ([String: String]) -> Void
    ) {
        self.refreshDeviceListCall = refreshDeviceListCall
        self.completion = completion
        _activityShowing = isLoading
        fetchRequest = FetchRequest<CDTestDevice>(
            entity: CDTestDevice.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "server.id == %@", serverID)
        )
        initialIds = deviceIDs
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Available simulators")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Refresh list…", action: refreshDeviceListCall)
                        .buttonStyle(LinkButtonStyle())
                }
                .padding()
                List {
                    ForEach(fetchRequest.wrappedValue, id: \.listID) { item in
                        SelectableListRow(title: item.listTitle, isSelected: selectionKeeper.contains(item.listID)) {
                            if selectionKeeper.contains(item.listID) {
                                selectionKeeper.remove(item.listID)
                            } else {
                                selectionKeeper.insert(item.listID)
                            }
                        }
                        .listRowBackground(selectionKeeper.contains(item.listID) ? Color.white: Color.lightBackground)
                    }
                }
                .listStyle(PlainListStyle())
                .border(Color.lightBackground, width: 1)
                HStack {
                    Spacer()
                    Button("Cancel") {
                        presentation.wrappedValue.dismiss()
                    }
                    .padding(.trailing)
                    Button("Ok") {
                        completion(testDevicesHash)
                        presentation.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
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
        .onAppear {
            initialIds.forEach { key in
                selectionKeeper.insert(key)
            }
        }
    }
    
    private var testDevicesHash: [String: String] {
        return Array(selectionKeeper).reduce([String: String]()) { devicesList, identifier in
            guard let name = viewContext.deviceName(for: identifier) else {
                // we do not return unknown IDs
                // IDs which apparently do not exist anymore on this server
                // will be discarded and thus removed
                return devicesList
            }
            var devicesList = devicesList
            devicesList[identifier] = name
            return devicesList
        }
    }
}
