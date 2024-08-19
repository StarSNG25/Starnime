//
//  AnimeListView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

struct AnimeListView: View
{
	@State private var animeList: [Anime] = []
	@State private var pagination: Pagination?
	@State private var latestSeason: Season?
	@State private var errorMessage: String?
	@State private var year: Int?
	@State private var season: String?
	@State private var page = 1
	
	var body: some View
	{
		#if os(macOS)
			Spacer()
		#endif
		
		NavigationStack
		{
			Text("Seasonal Anime")
				.font(.title)
				.fontWeight(.bold)
			
			if let animeIndex = animeList.firstIndex(where: { $0.currSeason != "" })
			{
				let currSeason = animeList[animeIndex].currSeason
				let nextSeason = animeList[animeIndex].nextSeason
				let prevSeason = animeList[animeIndex].prevSeason
				let isUpcoming = season?.caseInsensitiveCompare("upcoming") == .orderedSame
				
				HStack
				{
					if isUpcoming
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
					}
					else
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
					}
					
					if isUpcoming
					{
						Text("Later")
							.font(.title3)
							.fixedSize()
							.frame(maxWidth: .infinity)
					}
					else
					{
						Text(currSeason)
							.font(.title3)
							.fixedSize()
							.frame(maxWidth: .infinity)
					}
					
					if isUpcoming
					{
						Text("")
							.frame(maxWidth: .infinity, alignment: .trailing)
					}
					else if currSeason != latestSeason?.string
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
				.padding(.horizontal, 8)
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
									Text(anime.title)
										.font(.title)
										.foregroundColor(.primary)
//									Text(anime.title_japanese!)
//										.font(.title3)
//										.foregroundColor(.primary)
//									Text(anime.title_english!)
//										.font(.title3)
//										.foregroundColor(.primary)
									
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
								.padding(.horizontal)
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
				}
				else if let errorMessage = errorMessage
				{
					Text(errorMessage)
						.foregroundColor(.red)
				}
				else
				{
					ProgressView("Loading")
				}
			}
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
	}
	
	func fetchSeason() async
	{
		NetworkManager().fetchAnimeSeason(year: self.year, season: self.season, page: self.page)
		{ result in
			switch result
			{
				case .success(let animeListResponse):
					DispatchQueue.main.async
					{
						self.animeList.append(contentsOf: animeListResponse.data)
						self.pagination = animeListResponse.pagination
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
		}
	}
	
	func resetPage()
	{
		animeList = []
		page = 1
	}
}

#Preview
{
    AnimeListView()
}
