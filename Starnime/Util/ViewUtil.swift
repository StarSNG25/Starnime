//
//  ViewUtil.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/22.
//

import Foundation

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

func removeDuplicateAnime(animeListResponse: AnimeListResponse) -> [Anime]
{
	var seenIDs = Set<Int>()
	
	return animeListResponse.data.filter
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
}
