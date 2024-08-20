//
//  AnimeDetailsView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

struct AnimeDetailsView: View
{
	@State private var anime: Anime?
	@State private var errorMessage: String?
	let malId: Int

	var body: some View
	{
		ZStack
		{
			ScrollView
			{
				VStack
				{
					if let anime = anime
					{
						Group
						{
							Text(anime.title)
								.font(.title)
							if let title = anime.title_japanese
							{
								Spacer()
								Text(title)
									.font(.title3)
							}
							if let title = anime.title_english
							{
								Spacer()
								Text(title)
									.font(.title3)
							}
						}
						.multilineTextAlignment(.center)
						
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
						}
						
						if let synopsis = anime.synopsis
						{
							Text(synopsis)
								.padding(.vertical)
						}
						
						if let episodes = anime.episodes
						{
							Text("Episodes: \(episodes)")
						}
						
						Text(anime.status)
						
						if !anime.currSeason.isEmpty
						{
							Text(anime.currSeason)
						}
						
						if let score = anime.score
						{
							Text("Score: \(String(format: "%.2f", score))/10")
						}
						
						Link("MyAnimeList", destination: URL(string: anime.url)!)
					}
					else if let errorMessage = errorMessage
					{
						Text(errorMessage)
							.foregroundColor(.red)
					}
				}
				.padding(.horizontal, 8)
			}
			
			if anime == nil && errorMessage == nil
			{
				ProgressView("Loading")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.onAppear
		{
			Task
			{
				await fetchAnime()
			}
		}
		.refreshable
		{
			await fetchAnime()
		}
		.navigationTitle("Details")
	}
	
	func fetchAnime() async
	{
		errorMessage = nil
		
		NetworkManager().fetchAnimeDetails(for: malId)
		{ result in
			switch result
			{
				case .success(let animeResponse):
					DispatchQueue.main.async
					{
						self.anime = animeResponse.data
					}
				case .failure(let error):
					DispatchQueue.main.async
					{
						self.errorMessage = error.localizedDescription
					}
			}
		}
	}
}

#Preview
{
	AnimeDetailsView(malId: 54744)
}
