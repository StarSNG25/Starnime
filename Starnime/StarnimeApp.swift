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
	@Environment(\.scenePhase) private var scenePhase
	
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
		#if os(macOS)
			.defaultSize(width: 1280, height: 720)
			.onChange(of: scenePhase)
			{ oldPhase, newPhase in
				if newPhase == .background
				{
					navigationManager.path = NavigationPath()
				}
			}
		#endif
	}
}
