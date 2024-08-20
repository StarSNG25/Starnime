//
//  Settings.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/20.
//

import Foundation

class Settings: ObservableObject
{
	private let darkModeKey = "isDarkMode"
	private let titleLanguageKey = "titleLanguage"
	
	@Published var isDarkMode: Bool
	{
		didSet
		{
			UserDefaults.standard.set(isDarkMode, forKey: darkModeKey)
		}
	}
	@Published var titleLanguage: TitleLanguage
	{
		didSet
		{
			UserDefaults.standard.set(titleLanguage.rawValue, forKey: titleLanguageKey)
		}
	}
	
	init()
	{
		self.isDarkMode = UserDefaults.standard.object(forKey: darkModeKey) as? Bool ?? true
		self.titleLanguage = TitleLanguage(rawValue: UserDefaults.standard.string(forKey: titleLanguageKey) ?? TitleLanguage.default.rawValue) ?? .default
	}
}

enum TitleLanguage: String, CaseIterable, Identifiable
{
	var id: String { self.rawValue }
	
	case `default` = "Default"
	case japanese  = "Japanese"
	case english   = "English"
}
