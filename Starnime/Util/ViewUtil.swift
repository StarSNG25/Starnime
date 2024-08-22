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
