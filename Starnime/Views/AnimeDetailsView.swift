//
//  AnimeDetailsView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

struct AnimeDetailsView: View
{
	@EnvironmentObject var viewModel: AnimeDetailsViewModel
	
	var body: some View
	{
		ZStack
		{
			ScrollView
			{
				VStack
				{
					if let anime = viewModel.anime
					{
						VStack(spacing: 8)
						{
							Text(anime.title)
								.font(.title)
							if let title = anime.title_japanese, title != anime.title
							{
								Text(title)
									.font(.title3)
							}
							if let title = anime.title_english, title != anime.title
							{
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
									.frame(maxWidth: 380)
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
						
						if let rating = anime.rating
						{
							Text("Rating: \(rating)")
						}
						
						Link("MyAnimeList", destination: URL(string: anime.url)!)
					}
					else if let errorMessage = viewModel.errorMessage
					{
						ErrorMessageView(errorMessage: errorMessage)
					}
				}
				.padding(.horizontal, 8)
			}
			
			if viewModel.anime == nil && viewModel.errorMessage == nil
			{
				ProgressView("Loading")
			}
		}
		.onAppear
		{
			Task
			{
				await viewModel.fetchAnime()
			}
		}
		.refreshable
		{
			await viewModel.fetchAnime()
		}
		.navigationTitle("Details")
	}
}

#Preview
{
	NavigationStack
	{
		AnimeDetailsView()
	}
	.environmentObject(AnimeDetailsViewModel(malId: 54744))
}
