//
//  AnimeSearchViewModel.swift
//  Starnime
//
//  Created by Star_SNG on 2024/11/19.
//

import SwiftUI
import Combine

@MainActor
final class AnimeSearchViewModel: ObservableObject
{
	@Published var searchText: String = ""
	@Published var searchQuery: String = ""
	@Published var animeList: [Anime] = []
	@Published var pagination: Pagination?
	@Published var errorMessage: String?
	@Published var page = 1
	@Published var isLoading = false
	
	private var seenIDs = Set<Int>()
	private var fetchTask: Task<Void, Never>?
	private var settings = Settings()
	
	func fetchSearch() async
	{
		fetchTask?.cancel()
		
		fetchTask = Task
		{
			if searchQuery.isEmpty { return }
			
			isLoading = true
			
			defer { isLoading = false }
			
			do
			{
				let animeListResponse = try await NetworkManager()
					.fetchAnimeSearch(searchQuery: searchQuery, page: page, hideNSFW: settings.hideNSFW)
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
			}
			catch
			{
				errorMessage = error.localizedDescription
			}
		}
	}
	
	func displayTitle(for anime: Anime) -> String
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
