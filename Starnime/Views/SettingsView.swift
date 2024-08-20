//
//  SettingsView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/20.
//

import SwiftUI

struct SettingsView: View
{
	@StateObject private var settings = Settings()
	
	var body: some View
	{
		Form
		{
			Section(header: Text("Appearance"))
			{
				Toggle("Dark Mode", isOn: $settings.isDarkMode)
				Picker("Title Language", selection: $settings.titleLanguage)
				{
					ForEach(TitleLanguage.allCases)
					{ language in
						Text(language.rawValue).tag(language)
					}
				}
			}
		}
		.navigationTitle("Settings")
	}
}

#Preview
{
    SettingsView()
}
