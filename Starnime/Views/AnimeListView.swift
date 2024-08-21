//
//  AnimeListView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

struct AnimeListView: View
{
	@EnvironmentObject var settings: Settings
	@State private var animeList: [Anime] = []
	@State private var pagination: Pagination?
	@State private var latestSeason: Season?
	@State private var errorMessage: String?
	@State private var year: Int?
	@State private var season: String?
	@State private var seenIDs = Set<Int>()
	@State private var page = 1
	@State private var isLoading = false
	@State private var isUpcoming = false
	
	var body: some View
	{
		NavigationStack
		{
			HStack
			{
				Image(systemName: "gear")
					.font(.title)
					.opacity(0)
				
				Text("Seasonal Anime")
					.font(.title)
					.fontWeight(.bold)
					.frame(maxWidth: .infinity, alignment: .center)
				
				NavigationLink(destination: SettingsView())
				{
					Image(systemName: "gear")
						.font(.title)
				}
			}
			#if os(iOS)
				.padding(.horizontal, 8)
			#endif
			.padding(.bottom, 1)
			
			if let animeIndex = animeList.firstIndex(where: { $0.currSeason != "" })
			{
				let currSeason = animeList[animeIndex].currSeason
				let nextSeason = animeList[animeIndex].nextSeason
				let prevSeason = animeList[animeIndex].prevSeason
				
				HStack
				{
					Button(action: {
						Task
						{
							resetPage()
							year = prevSeason.year
							season = prevSeason.season
							await fetchSeason()
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
					
					if currSeason != latestSeason?.string
					{
						Button(action: {
							Task
							{
								resetPage()
								year = nextSeason.year
								season = nextSeason.season
								await fetchSeason()
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
								resetPage()
								season = "upcoming"
								await fetchSeason()
							}
						}, label: {
							Text("Later")
								.font(.subheadline)
						})
						.frame(maxWidth: .infinity, alignment: .trailing)
					}
				}
				#if os(iOS)
					.padding(.horizontal, 8)
				#endif
			}
			else if isUpcoming
			{
				HStack
				{
					Button(action: {
						Task
						{
							resetPage()
							year = latestSeason!.year
							season = latestSeason!.season
							await fetchSeason()
						}
					}, label: {
						Text(latestSeason!.string)
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
				#if os(iOS)
					.padding(.horizontal, 8)
				#endif
			}
			
			ScrollView
			{
				if !animeList.isEmpty
				{
					LazyVStack
					{
						ForEach(animeList)
						{ anime in
							NavigationLink(destination: AnimeDetailsView(malId: anime.mal_id))
							{
								VStack
								{
									Text(displayTitle(for: anime))
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
									#if os(macOS)
										.opacity(0)
									#endif
								}
								.padding(.horizontal, 8)
								#if os(macOS)
									.padding(.top, 8)
								#endif
								.onAppear
								{
									if anime.mal_id == animeList.last?.mal_id && pagination!.has_next_page
									{
										Task
										{
											page += 1
											await fetchSeason()
										}
									}
								}
							}
						}
					}
					
					if isLoading
					{
						ProgressView()
					}
				}
				else if let errorMessage = errorMessage
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
			#if os(macOS)
				.cornerRadius(8)
			#endif
		}
		.onAppear
		{
			Task
			{
				await fetchSeason()
				latestSeason = await NetworkManager().getLatestSeason()
			}
		}
		.refreshable
		{
			resetPage()
			await fetchSeason()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		#if os(macOS)
			.padding()
		#endif
	}
	
	private func fetchSeason() async
	{
		isLoading = true
		
		NetworkManager().fetchAnimeSeason(year: self.year, season: self.season, page: self.page)
		{ result in
			switch result
			{
				case .success(let animeListResponse):
					DispatchQueue.main.async
					{
						let animeList = animeListResponse.data.filter
						{ anime in
							if seenIDs.contains(anime.mal_id)
							{
								return false
							}
							else
							{
								seenIDs.insert(anime.mal_id)
								return true
							}
						}
						self.animeList.append(contentsOf: animeList)
						self.pagination = animeListResponse.pagination
						
						isUpcoming = season?.caseInsensitiveCompare("upcoming") == .orderedSame
						if isUpcoming
						{
							self.animeList.removeAll(where: { $0.season != nil })
						}
						
//						if self.pagination == nil
//						{
//							self.pagination = animeList.pagination
//						}
					}
				case .failure(let error):
					DispatchQueue.main.async
					{
						self.errorMessage = error.localizedDescription
					}
			}
			isLoading = false
		}
	}
	
	private func resetPage()
	{
		animeList = []
		seenIDs = Set<Int>()
		page = 1
		errorMessage = nil
	}
	
	private func displayTitle(for anime: Anime) -> String
	{
		switch settings.titleLanguage
		{
			case .default:
				return anime.title
			case .japanese:
				return anime.title_japanese ?? anime.title
			case .english:
				return anime.title_english ?? anime.title
		}
	}
}

#Preview
{
    AnimeListView()
		.environmentObject(Settings())
}
