//
//  AnimeListView_macOS.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/21.
//

import SwiftUI

struct AnimeListView_macOS: View
{
	@EnvironmentObject var viewModel: AnimeListViewModel
	@EnvironmentObject var settings: Settings
	
	var body: some View
	{
		NavigationStack
		{
			HStack
			{
				Text("")
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Text("Seasonal Anime")
					.font(.title)
					.fontWeight(.bold)
					.fixedSize()
					.frame(maxWidth: .infinity)
				
				NavigationLink(destination: SettingsView())
				{
					Image(systemName: "gear")
						.font(.title)
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
			}
			.padding(.bottom, 1)
			
			if let animeIndex = viewModel.animeList.firstIndex(where: { $0.currSeason != "" })
			{
				let currSeason = viewModel.animeList[animeIndex].currSeason
				let nextSeason = viewModel.animeList[animeIndex].nextSeason
				let prevSeason = viewModel.animeList[animeIndex].prevSeason
				
				HStack
				{
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
			}
			else if viewModel.isUpcoming
			{
				HStack
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
			
			ScrollView
			{
				if !viewModel.animeList.isEmpty
				{
					LazyVStack
					{
						ForEach(viewModel.animeList)
						{ anime in
							NavigationLink(destination: AnimeDetailsView(malId: anime.mal_id))
							{
								VStack
								{
									Text(viewModel.displayTitle(for: anime, settings: settings))
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
										.opacity(0)
								}
								.padding(.horizontal, 8)
								.padding(.top, 8)
								.onAppear
								{
									if anime.mal_id == viewModel.animeList.last?.mal_id && viewModel.pagination!.has_next_page
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
					Text(errorMessage)
						.foregroundColor(.red)
				}
				else
				{
					ZStack
					{
						Spacer()
							.containerRelativeFrame([.horizontal, .vertical])
						ProgressView("Loading")
					}
				}
			}
			.cornerRadius(8)
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
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
	}
}

#Preview
{
	AnimeListView_macOS()
		.environmentObject(AnimeListViewModel())
		.environmentObject(Settings())
}
