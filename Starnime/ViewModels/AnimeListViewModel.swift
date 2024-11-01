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
	private var fetchTask: Task<Void, Never>?
	
	func fetchSeason() async
	{
		fetchTask?.cancel()
		
		fetchTask = Task
		{
			isLoading = true
			
			defer
			{
				isLoading = false
			}
			
			do
			{
				let animeListResponse = try await NetworkManager().fetchAnimeSeason(year: year, season: season, page: page)
				let animeList = animeListResponse.data.filter
				{ anime in
					guard !seenIDs.contains(anime.mal_id) else {
						return false
					}
					
					seenIDs.insert(anime.mal_id)
					return true
				}
				self.animeList.append(contentsOf: animeList)
				self.pagination = animeListResponse.pagination
				
				isUpcoming = season?.caseInsensitiveCompare("upcoming") == .orderedSame
				if isUpcoming
				{
					self.animeList.removeAll(where: { $0.season != nil })
				}
			}
			catch
			{
				self.errorMessage = error.localizedDescription
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
