//
//  AnimeDetailsViewModel.swift
//  Starnime
//
//  Created by Star_SNG on 2024/11/01.
//

import SwiftUI
import Combine

@MainActor
final class AnimeDetailsViewModel: ObservableObject
{
	@Published var anime: Anime?
	@Published var errorMessage: String?
	
	private let malId: Int
	
	init(malId: Int)
	{
		self.malId = malId
	}
	
	func fetchAnime() async
	{
		errorMessage = nil
		
		do
		{
			let animeResponse = try await NetworkManager().fetchAnimeDetails(for: malId)
			anime = animeResponse.data
		}
		catch
		{
			errorMessage = error.localizedDescription
		}
	}
}
