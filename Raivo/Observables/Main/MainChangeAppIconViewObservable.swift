//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import Combine

final class MainChangeAppIconViewObservable: ObservableObject {
    
    @Published var icons: [AppIconObject] = []
    
    @Published var index = 0
    
    init() {
        fetchPrimaryIcon("1. Light (small)")
        fetchAlternateIcons()
        
        if let currentIcon = getAppPrincipal().alternateIconName {
            for (index, icon) in icons.enumerated() {
                if icon.key == currentIcon {
                    self.index = index
                }
            }
        }
    }
    
    func getSelected(_ index: Int? = nil) -> AppIconObject {
        let index = index ?? self.index
        return icons[index]
    }
    
    func fetchPrimaryIcon(_ name: String? = nil) {
        if let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any] {
            guard let primary = value["CFBundlePrimaryIcon"] as? Dictionary<String, Any> else { return }
            guard let iconFiles = primary["CFBundleIconFiles"] as? [String] else { return }
            guard let icon = iconFiles.first else { return }
            self.icons.append(AppIconObject(icon, name ?? "Primary", true))
        }
    }
    
    func fetchAlternateIcons() {
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let alternateIcons = icons["CFBundleAlternateIcons"] as? [String: Any] {
            for (_, value) in alternateIcons {
                guard let iconList = value as? Dictionary<String, Any> else { continue }
                guard let iconFiles = iconList["CFBundleIconFiles"] as? [String] else { continue }
                guard let icon = iconFiles.first else { continue }
                guard let name = iconList["Name"] as? String else { continue }
                self.icons.append(AppIconObject(icon, name))
            }
        }
        
        self.icons = self.icons.sorted { $0.name < $1.name }
    }

}
