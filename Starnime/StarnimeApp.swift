//
//  StarnimeApp.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

@main
struct StarnimeApp: App
{
	@StateObject private var settings = Settings()
	
	var body: some Scene
	{
		WindowGroup
		{
			AnimeListView()
				.environmentObject(settings)
				.preferredColorScheme(settings.isDarkMode ? .dark : .light)
		}
	}
}
