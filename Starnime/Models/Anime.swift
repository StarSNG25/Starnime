//
//  Anime.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import Foundation

struct Anime: Codable, Identifiable
{
	var id: Int? { mal_id }
	let mal_id: Int
	let url: String
	let images: Images
	let title: String
	let title_japanese: String?
	let title_english: String?
	let title_synonyms: [String]?
	let type: String?
	let source: String
	let episodes: Int?
	let status: String
	let airing: Bool
	let aired: Aired
	let duration: String
	let rating: String?
	let score: Double?
	let scored_by: Int?
	let rank: Int?
	let popularity: Int
	let members: Int
	let favorites: Int
	let synopsis: String?
	let season: String?
	let year: Int?
	let broadcast: Broadcast?
	
	var currSeason: String
	{
		guard let season = season?.capitalizedFirstLetter, let year = year
		else
		{
			return ""
		}
		return "\(season) \(year)"
	}
	var nextSeason: Season
	{
		return getAdjacentSeason(year: year, season: season, getNext: true)
	}
	var prevSeason: Season
	{
		return getAdjacentSeason(year: year, season: season, getNext: false)
	}
}

struct Images: Codable
{
	let webp: ImageFormat
}

struct ImageFormat: Codable
{
	let large_image_url: String
}

struct Aired: Codable
{
	let from, to: String?
	let prop: AiredProp?
	let string: String?
}

struct AiredProp: Codable
{
	let from, to: AiredPropDetails?
}

struct AiredPropDetails: Codable
{
	let day, month, year: Int?
}

struct Broadcast: Codable
{
	let day, time, timezone, string: String?
}

struct Season: Codable
{
	let string: String
	let season: String?
	let year: Int?
}

private func getAdjacentSeason(year: Int?, season: String?, getNext: Bool) -> Season
{
	var adjacentYear = year
	var adjacentSeason = ""
	
	if (getNext)
	{
		switch (season)
		{
			case "winter":
				adjacentSeason = "Spring"
			case "spring":
				adjacentSeason = "Summer"
			case "summer":
				adjacentSeason = "Fall"
			case "fall":
				adjacentSeason = "Winter"
				adjacentYear   = year! + 1
			default:
				adjacentSeason = ""
		}
	}
	else
	{
		switch (season)
		{
			case "winter":
				adjacentSeason = "Fall"
				adjacentYear   = year! - 1
			case "spring":
				adjacentSeason = "Winter"
			case "summer":
				adjacentSeason = "Spring"
			case "fall":
				adjacentSeason = "Summer"
			default:
				adjacentSeason = ""
		}
	}
	
	return Season(string: adjacentSeason + " " + String(adjacentYear ?? 0), season: adjacentSeason, year: adjacentYear)
}

struct Pagination: Codable
{
	let last_visible_page: Int
	let has_next_page: Bool
	let current_page: Int
	let items: PaginationItems
}

struct PaginationItems: Codable
{
	let count, total, per_page: Int
}
