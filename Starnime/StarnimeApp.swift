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
	@StateObject private var viewModel = AnimeSeasonalViewModel()
	@StateObject private var navigationManager = NavigationManager()
	
	var body: some Scene
	{
		WindowGroup
		{
			NavigationStack(path: $navigationManager.path)
			{
				#if os(macOS)
					AnimeSeasonalView_macOS()
				#else
					AnimeSeasonalView()
				#endif
			}
			.environmentObject(viewModel)
			.environmentObject(settings)
			.environmentObject(navigationManager)
			.preferredColorScheme(settings.isDarkMode ? .dark : .light)
		}
	}
}
