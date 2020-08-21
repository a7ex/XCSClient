//
//  TestDeviceSpecification.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 04.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

/// Available deviceIdentifiers can be found on the server machine with
/// ```
/// sudo xcscontrol --list-devices
/// sudo xcscontrol --list-simulators
/// ```
/// The filter defines which OS shall run on the simulator
///
struct TestDeviceSpecification: Codable {
    var deviceIdentifiers: [String]?
    var filters: [TestDeviceFilter]?
}
