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
	@StateObject private var viewModel = AnimeListViewModel()
	
	var body: some Scene
	{
		WindowGroup
		{
			#if os(macOS)
				AnimeListView_macOS()
					.environmentObject(viewModel)
					.environmentObject(settings)
					.preferredColorScheme(settings.isDarkMode ? .dark : .light)
			#else
				AnimeListView()
					.environmentObject(viewModel)
					.environmentObject(settings)
					.preferredColorScheme(settings.isDarkMode ? .dark : .light)
			#endif
		}
	}
}
