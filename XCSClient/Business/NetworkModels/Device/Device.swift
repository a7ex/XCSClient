//
//  Device.swift
//  XCSClient
//
//  Created by Alex da Franca on 03.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

extension Device {
    static func testDevice() {
        let listString = """
    
         ID: ca289ed30dbbe31a4b703019e8108de5
       Name: iPhone-11-Pro-iOS-14.0
    Identifier: AB2372BE-2BFF-44F3-85C8-39A3F4065615
       UDID: (null)
       ECID: (null)
     Serial: (null)
       Type: com.apple.iphone-simulator
      Model: iPhone 11 Pro (iPhone12,3)
       Arch: x86_64
         OS: 14.0.1
    Processor: (null)
        UTI: com.apple.iphone-11-pro-1
    Platform: com.apple.platform.iphonesimulator
    Simulator: 1
    Connected: 1
    Supported: 1
    Development: 1
    Trusted: 1
    
         ID: cc9d81746914212693b3b4b3ba0070a5
       Name: iPad (7th generation)
    Identifier: 8A7C0357-3F7B-49EB-B1C2-A7B2471A9717
       UDID: (null)
       ECID: (null)
     Serial: (null)
       Type: com.apple.iphone-simulator
      Model: iPad (7th generation) (iPad7,12)
       Arch: x86_64
         OS: 13.6
    Processor: (null)
        UTI: com.apple.ipad-7-wwan-1
    Platform: com.apple.platform.iphonesimulator
    Simulator: 1
    Connected: 0
    Supported: 1
    Development: 1
    Trusted: 1
    
         ID: cc9d81746914212693b3b4b3ba007d91
       Name: iPhone 11
    Identifier: BCBEBE95-10AF-4852-973E-B26CEA1D2C5D
       UDID: (null)
       ECID: (null)
     Serial: (null)
       Type: com.apple.iphone-simulator
      Model: iPhone 11 (iPhone12,1)
       Arch: x86_64
         OS: 14.2
    Processor: (null)
        UTI: com.apple.iphone-11-1
    Platform: com.apple.platform.iphonesimulator
    Simulator: 1
    Connected: 1
    Supported: 1
    Development: 1
    Trusted: 1
    
         ID: cc9d81746914212693b3b4b3ba007e71
       Name: iPhone 11 Pro
    Identifier: DAB08FDD-8641-4836-92C2-FB88A5C70D66
       UDID: (null)
       ECID: (null)
     Serial: (null)
       Type: com.apple.iphone-simulator
      Model: iPhone 11 Pro (iPhone12,3)
       Arch: x86_64
         OS: 13.3
    Processor: (null)
        UTI: com.apple.iphone-11-pro-1
    Platform: com.apple.platform.iphonesimulator
    Simulator: 1
    Connected: 0
    Supported: 1
    Development: 1
    Trusted: 1
             (Proxying Apple Watch Series 5 - 40mm [5EF0A27E-1133-4C66-A4A8-60D676F456B3])
    """
        let devs = getRecordList(from: listString)
        let devices = devs.map { Device(dictionary: $0) }
        print("\(devices)")
    }
    static func getRecordList(from deviceListAsString: String) -> [[String: String]] {
        let records = deviceListAsString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n\n")
        return records.map { record in
            var additionalArgumentsKey = 1
            return record.components(separatedBy: "\n")
                .reduce([String: String]()) { deviceDictionary, keyValueString in
                    var deviceDictionary = deviceDictionary
                    let parts = keyValueString.components(separatedBy: ":")
                    guard let key = parts.first?.trimmingCharacters(in: .whitespaces),
                          !key.isEmpty else {
                        return deviceDictionary
                    }
                    if parts.count < 2 {
                        deviceDictionary["additionalInfos\(additionalArgumentsKey)"] = key
                        additionalArgumentsKey += 1
                    } else {
                        deviceDictionary[key] = parts
                            .dropFirst()
                            .joined(separator: ":")
                            .trimmingCharacters(in: .whitespaces)
                    }
                    return deviceDictionary
                }
        }
    }
}

struct Device {
    let id: String?
    let name: String?
    let identifier: String?
    let udid: String?
    let ecid: String?
    let serial: String?
    let type: String?
    let model: String?
    let arch: String?
    let os: String?
    let processor: String?
    let uti: String?
    let platform: String?
    let simulator: Bool?
    let connected: Bool?
    let supported: Bool?
    let development: Bool?
    let trusted: Bool?
    let additionalInfos: [String]
    
    enum DictionaryKeys: String {
        case id = "ID"
        case name = "Name"
        case identifier = "Identifier"
        case udid = "UDID"
        case ecid = "ECID"
        case serial = "Serial"
        case type = "Type"
        case model = "Model"
        case arch = "Arch"
        case os = "OS"
        case processor = "Processor"
        case uti = "UTI"
        case platform = "Platform"
        case simulator = "Simulator"
        case connected = "Connected"
        case supported = "Supported"
        case development = "Development"
        case trusted = "Trusted"
    }
}

extension Device {
    init(dictionary: [String: String]) {
        id = dictionary[DictionaryKeys.id.rawValue]
        name = dictionary[DictionaryKeys.name.rawValue]
        identifier = dictionary[DictionaryKeys.identifier.rawValue]
        udid = dictionary[DictionaryKeys.udid.rawValue]
        ecid = dictionary[DictionaryKeys.ecid.rawValue]
        serial = dictionary[DictionaryKeys.serial.rawValue]
        type = dictionary[DictionaryKeys.type.rawValue]
        model = dictionary[DictionaryKeys.model.rawValue]
        arch = dictionary[DictionaryKeys.arch.rawValue]
        os = dictionary[DictionaryKeys.os.rawValue]
        processor = dictionary[DictionaryKeys.processor.rawValue]
        uti = dictionary[DictionaryKeys.uti.rawValue]
        platform = dictionary[DictionaryKeys.platform.rawValue]
        simulator = dictionary[DictionaryKeys.simulator.rawValue] == "1"
        connected = dictionary[DictionaryKeys.connected.rawValue] == "1"
        supported = dictionary[DictionaryKeys.supported.rawValue] == "1"
        development = dictionary[DictionaryKeys.development.rawValue] == "1"
        trusted = dictionary[DictionaryKeys.trusted.rawValue] == "1"
        var adds = [String]()
        var additionalArgumentsKey = 1
        while let value = dictionary["additionalInfos\(additionalArgumentsKey)"] {
            adds.append(value)
            additionalArgumentsKey += 1
        }
        additionalInfos = adds
    }
}
