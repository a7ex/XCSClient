//
//  FileHelper.swift
//  XCSClient
//
//  Created by Alex da Franca on 20.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import AppKit

struct FileHelper {
    func getSaveURLFromUser(for fileName: String) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = fileName
        let result = panel.runModal()
        guard result == .OK else {
            return nil
        }
        return panel.url
    }
}
