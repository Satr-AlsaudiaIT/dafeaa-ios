//
//  FileManger+ext.swift
//  
//
//  Created by M.Magdy on 06/09/2023.
//  Copyright © 2023  Nura. All rights reserved.
//

import Foundation
extension FileManager {
    func getDownloadsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Downloads")
    }
}
