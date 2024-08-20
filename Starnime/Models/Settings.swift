//
//  Settings.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/20.
//

import Foundation
import SwiftUI

class Settings: ObservableObject
{
	@AppStorage("isDarkMode") var isDarkMode: Bool = true
	@AppStorage("titleLanguage") var titleLanguage: TitleLanguage = .default
}

enum TitleLanguage: String, CaseIterable, Identifiable
{
	var id: String { self.rawValue }
	
	case `default` = "Default"
	case japanese  = "Japanese"
	case english   = "English"
}
