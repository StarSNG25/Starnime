//
//  NetworkManager.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import Foundation

class NetworkManager
{
	private let session: URLSession
	private var invalidURLError: NSError
	{
		return NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
	}
	
	init()
	{
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		self.session = URLSession(configuration: config)
	}
	
	func fetchAnimeSeason(year: Int?, season: String?, page: Int) async throws -> AnimeListResponse
	{
		var urlString: String
		
		if year == nil && season == nil
		{
			urlString = "https://api.jikan.moe/v4/seasons/now?page=\(page)"
		}
		else if season!.caseInsensitiveCompare("upcoming") == .orderedSame
		{
			urlString = "https://api.jikan.moe/v4/seasons/upcoming?page=\(page)"
		}
		else
		{
			urlString = "https://api.jikan.moe/v4/seasons/\(year!)/\(season!)?page=\(page)"
		}
		
		guard let url = URL(string: urlString) else {
			throw invalidURLError
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		let (data, _) = try await session.data(for: request)
		let animeListResponse = try JSONDecoder().decode(AnimeListResponse.self, from: data)
		return animeListResponse
	}
	
	func fetchAnimeDetails(for id: Int) async throws -> AnimeResponse
	{
		let urlString = "https://api.jikan.moe/v4/anime/\(id)"
		
		guard let url = URL(string: urlString) else {
			throw invalidURLError
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		let (data, _) = try await session.data(for: request)
		let animeResponse = try JSONDecoder().decode(AnimeResponse.self, from: data)
		return animeResponse
	}
	
	func fetchSeasonsList() async throws -> SeasonsListResponse
	{
		let urlString = "https://api.jikan.moe/v4/seasons"
		
		guard let url = URL(string: urlString) else {
			throw invalidURLError
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		let (data, _) = try await session.data(for: request)
		let seasonsListResponse = try JSONDecoder().decode(SeasonsListResponse.self, from: data)
		return seasonsListResponse
	}
	
	func getLatestSeason() async -> Season
	{
		do
		{
			let seasonsListResponse = try await fetchSeasonsList()
			let season = seasonsListResponse.data.first?.seasons.last?.capitalized
			let year = seasonsListResponse.data.first?.year
			return Season(string: season! + " " + String(year!), season: season, year: year)
		}
		catch
		{
			return Season(string: error.localizedDescription, season: "", year: 0)
		}
	}
}

struct AnimeResponse: Codable
{
	let data: Anime
}

struct AnimeListResponse: Codable
{
	let pagination: Pagination
	let data: [Anime]
}

struct SeasonsListResponse: Codable
{
	let data: [Seasons]
}
