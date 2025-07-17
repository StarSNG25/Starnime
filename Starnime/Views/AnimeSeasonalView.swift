//
//  AnimeListView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

#if !os(macOS)
import SwiftUI

struct AnimeSeasonalView: View
{
	@EnvironmentObject var viewModel: AnimeSeasonalViewModel
	@EnvironmentObject var settings: Settings
	@EnvironmentObject var navigationManager: NavigationManager
	@StateObject private var animeSearchViewModel = AnimeSearchViewModel()
	
	var body: some View
	{
		list
		.navigationTitle("Seasonal Anime")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar
		{
			ToolbarItem(placement: .navigationBarLeading)
			{
				NavigationLink(value: SeasonalNavigationDestination.settings)
				{
					Image(systemName: "gear")
						.font(.title2)
				}
			}
			
			ToolbarItem(placement: .principal)
			{
				Text("Seasonal Anime")
					.font(.title)
					.fontWeight(.bold)
			}
			
			ToolbarItem(placement: .navigationBarTrailing)
			{
				NavigationLink(value: SeasonalNavigationDestination.search )
				{
					Image(systemName: "magnifyingglass")
						.font(.title2)
				}
			}
			
			ToolbarItem(placement: .bottomBar)
			{
				navSeason
			}
		}
		.onAppear
		{
			Task
			{
				await viewModel.fetchSeason()
				viewModel.latestSeason = await NetworkManager().getLatestSeason()
			}
		}
		.refreshable
		{
			viewModel.resetPage()
			await viewModel.fetchSeason()
		}
		.onChange(of: settings.hideNSFW)
		{
			Task
			{
				viewModel.resetPage()
				await viewModel.fetchSeason()
			}
		}
		.onChange(of: navigationManager.path)
		{
			if navigationManager.path.isEmpty
			{
				animeSearchViewModel.resetPage()
				animeSearchViewModel.searchText = ""
				animeSearchViewModel.searchQuery = ""
			}
		}
		.navigationDestination(for: SeasonalNavigationDestination.self)
		{ destination in
			switch destination
			{
				case .settings:
					SettingsView()
				case .search:
					AnimeSearchView()
						.environmentObject(animeSearchViewModel)
				case .details(let malId):
					AnimeDetailsView()
						.environmentObject(AnimeDetailsViewModel(malId: malId))
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	private var navSeason: some View
	{
		HStack
		{
			if let animeIndex = viewModel.animeList.firstIndex(where: { $0.currSeason != "" })
			{
				let currSeason = viewModel.animeList[animeIndex].currSeason
				let nextSeason = viewModel.animeList[animeIndex].nextSeason
				let prevSeason = viewModel.animeList[animeIndex].prevSeason
				
				Button(action: {
					Task
					{
						viewModel.resetPage()
						viewModel.year = prevSeason.year
						viewModel.season = prevSeason.season
						await viewModel.fetchSeason()
					}
				}, label: {
					Text(prevSeason.string)
						.font(.subheadline)
				})
				.frame(maxWidth: .infinity, alignment: .leading)
				
				Text(currSeason)
					.font(.title3)
					.fixedSize()
					.frame(maxWidth: .infinity)
				
				if currSeason != viewModel.latestSeason?.string
				{
					Button(action: {
						Task
						{
							viewModel.resetPage()
							viewModel.year = nextSeason.year
							viewModel.season = nextSeason.season
							await viewModel.fetchSeason()
						}
					}, label: {
						Text(nextSeason.string)
							.font(.subheadline)
					})
					.frame(maxWidth: .infinity, alignment: .trailing)
				}
				else
				{
					Button(action: {
						Task
						{
							viewModel.resetPage()
							viewModel.season = "upcoming"
							await viewModel.fetchSeason()
						}
					}, label: {
						Text("Later")
							.font(.subheadline)
					})
					.frame(maxWidth: .infinity, alignment: .trailing)
				}
			}
			else if viewModel.isUpcoming
			{
				Button(action: {
					Task
					{
						viewModel.resetPage()
						viewModel.year = viewModel.latestSeason!.year
						viewModel.season = viewModel.latestSeason!.season
						await viewModel.fetchSeason()
					}
				}, label: {
					Text(viewModel.latestSeason!.string)
						.font(.subheadline)
				})
				.frame(maxWidth: .infinity, alignment: .leading)
				
				Text("Later")
					.font(.title3)
					.fixedSize()
					.frame(maxWidth: .infinity)
				
				Text("")
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
		}
	}
	
	private var list: some View
	{
		ScrollView
		{
			if !viewModel.animeList.isEmpty
			{
				LazyVStack
				{
					ForEach(viewModel.animeList)
					{ anime in
						NavigationLink(value: SeasonalNavigationDestination.details(malId: anime.mal_id))
						{
							VStack
							{
								Text(viewModel.displayTitle(for: anime))
									.font(.title)
									.foregroundColor(.primary)
								
								if let imageUrl = URL(string: anime.images.webp.large_image_url)
								{
									AsyncImage(url: imageUrl)
									{ image in
										image.resizable()
											.aspectRatio(contentMode: .fit)
											.cornerRadius(10)
									}
									placeholder:
									{
										ProgressView()
									}
									.frame(width: 300, height: 400)
								}
								
								if let episodes = anime.episodes
								{
									Text("Episodes: \(episodes)")
										.foregroundColor(.primary)
								}
								
								Text(anime.status)
									.foregroundColor(.primary)
								
								if let score = anime.score
								{
									Text("Score: \(String(format: "%.2f", score))/10")
										.foregroundColor(.primary)
								}
								
								Divider()
							}
							.padding(.horizontal, 8)
							.onAppear
							{
								if anime.mal_id == viewModel.animeList.last?.mal_id
									&& viewModel.pagination!.has_next_page
								{
									Task
									{
										viewModel.page += 1
										await viewModel.fetchSeason()
									}
								}
							}
						}
					}
				}
				
				if viewModel.isLoading
				{
					ProgressView()
				}
			}
			else if let errorMessage = viewModel.errorMessage
			{
				ErrorMessageView(errorMessage: errorMessage)
			}
			else
			{
				CenteredContainer
				{
					ProgressView("Loading")
				}
			}
		}
	}
}

#Preview
{
	NavigationStack
	{
		AnimeSeasonalView()
	}
	.environmentObject(AnimeSeasonalViewModel())
	.environmentObject(Settings())
	.environmentObject(NavigationManager())
}
#endif
