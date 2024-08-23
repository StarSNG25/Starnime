//
//  AnimeListViewModel.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/22.
//

import SwiftUI
import Combine

@MainActor
class AnimeListViewModel: ObservableObject
{
	@Published var animeList: [Anime] = []
	@Published var pagination: Pagination?
	@Published var latestSeason: Season?
	@Published var errorMessage: String?
	@Published var year: Int?
	@Published var season: String?
	@Published var page = 1
	@Published var isLoading = false
	@Published var isUpcoming = false
	
	private var seenIDs = Set<Int>()
	
	func fetchSeason() async
	{
		self.isLoading = true
		
		NetworkManager().fetchAnimeSeason(year: self.year, season: self.season, page: self.page)
		{ result in
			switch result
			{
				case .success(let animeListResponse):
					DispatchQueue.main.async
					{
						let animeList = animeListResponse.data.filter
						{ anime in
							if self.seenIDs.contains(anime.mal_id)
							{
								return false
							}
							else
							{
								self.seenIDs.insert(anime.mal_id)
								return true
							}
						}
						self.animeList.append(contentsOf: animeList)
						self.pagination = animeListResponse.pagination
						
						self.isUpcoming = self.season?.caseInsensitiveCompare("upcoming") == .orderedSame
						if self.isUpcoming
						{
							self.animeList.removeAll(where: { $0.season != nil })
						}
					}
				case .failure(let error):
					DispatchQueue.main.async
					{
						self.errorMessage = error.localizedDescription
					}
			}
			DispatchQueue.main.async
			{
				self.isLoading = false
			}
		}
	}
	
	func displayTitle(for anime: Anime, settings: Settings) -> String
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
	
	func resetPage()
	{
		animeList = []
		seenIDs = Set<Int>()
		page = 1
		errorMessage = nil
	}
}
