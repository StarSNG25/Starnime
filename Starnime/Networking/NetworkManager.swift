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
	
	init()
	{
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		self.session = URLSession(configuration: config)
	}
	
	func fetchAnimeSeason(year: Int?, season: String?, page: Int, completion: @escaping (Result<AnimeListResponse, Error>) -> Void)
	{
//		let urlString = year == nil || season == nil
//						? "https://api.jikan.moe/v4/seasons/now?page=\(page)"
//						: "https://api.jikan.moe/v4/seasons/\(year!)/\(season!)?page=\(page)"
		
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
			return
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		session.dataTask(with: request)
		{ data, response, error in
			if let error = error
			{
				completion(.failure(error))
				return
			}

			guard let data = data else {
				return
			}

			do
			{
				let animeListResponse = try JSONDecoder().decode(AnimeListResponse.self, from: data)
				completion(.success(animeListResponse))
			}
			catch
			{
				completion(.failure(error))
			}
		}.resume()
	}
	
	func fetchAnimeDetails(for id: Int, completion: @escaping (Result<AnimeResponse, Error>) -> Void)
	{
		let urlString = "https://api.jikan.moe/v4/anime/\(id)"
		
		guard let url = URL(string: urlString) else {
			return
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		session.dataTask(with: request)
		{ data, response, error in
			if let error = error
			{
				completion(.failure(error))
				return
			}

			guard let data = data else {
				return
			}

			do
			{
				let animeResponse = try JSONDecoder().decode(AnimeResponse.self, from: data)
				completion(.success(animeResponse))
			}
			catch
			{
				completion(.failure(error))
			}
		}.resume()
	}
	
	func getLatestSeason() async -> Season
	{
		let result = await fetchSeasonsList()
		
		switch result
		{
			case .success(let seasonsListResponse):
				let season = seasonsListResponse.data.first?.seasons.last?.capitalizedFirstLetter
				let year = seasonsListResponse.data.first?.year
				return Season(string: season! + " " + String(year!), season: season, year: year)
			case .failure(let error):
				return Season(string: error.localizedDescription, season: "", year: 0)
		}
	}
	
	func fetchSeasonsList() async -> Result<SeasonsListResponse, Error>
	{
		let urlString = "https://api.jikan.moe/v4/seasons"
		
		guard let url = URL(string: urlString) else {
			return .failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
		}
		
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		do
		{
			let (data, _) = try await session.data(for: request)
			let seasonsListResponse = try JSONDecoder().decode(SeasonsListResponse.self, from: data)
			return .success(seasonsListResponse)
		}
		catch
		{
			return .failure(error)
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
	let data: [SeasonsList]
}
