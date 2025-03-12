//
//  AnimeSearchView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/11/19.
//

import SwiftUI

struct AnimeSearchView: View
{
	@EnvironmentObject var viewModel: AnimeSearchViewModel
	@EnvironmentObject var settings: Settings
	@FocusState private var isSearchFieldFocused: Bool
	
	var body: some View
	{
		NavigationStack
		{
			header
			list
		}
		.onAppear
		{
			isSearchFieldFocused = viewModel.searchQuery.isEmpty ? true : false
		}
		.onTapGesture
		{
			isSearchFieldFocused = false
		}
		.refreshable
		{
			viewModel.searchText = viewModel.searchQuery
			isSearchFieldFocused = viewModel.searchQuery.isEmpty ? true : false
			viewModel.resetPage()
			await viewModel.fetchSearch()
		}
		.onChange(of: settings.hideNSFW)
		{
			Task
			{
				viewModel.resetPage()
				await viewModel.fetchSearch()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	private var header: some View
	{
		VStack
		{
			HStack
			{
				NavigationLink(destination: SettingsView())
				{
					Image(systemName: "gear")
						.font(.title)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
//				Text(!viewModel.searchText.isEmpty ? viewModel.searchText : "Search Anime")
				Text("Search Anime")
					.font(.title)
					.fontWeight(.bold)
					.fixedSize()
					.frame(maxWidth: .infinity)
				
				Text("")
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
			.padding(.bottom, 1)
//			.searchable(
//				text: $viewModel.searchText,
//				placement: .navigationBarDrawer(displayMode: .automatic)
//			)
			
			TextField("Search", text: $viewModel.searchText)
				.focused($isSearchFieldFocused)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.background(
					RoundedRectangle(cornerRadius: 4)
						.stroke(.accent, lineWidth: 2)
				)
				.onSubmit
				{
					Task
					{
						viewModel.resetPage()
						viewModel.searchQuery = viewModel.searchText
						await viewModel.fetchSearch()
					}
				}
		}
		.padding(.horizontal, 8)
	}
	
	private var list: some View
	{
		ScrollView
		{
			if !viewModel.animeList.isEmpty
			{
				LazyVStack
				{
					ForEach(viewModel.animeList)
					{ anime in
						NavigationLink(
							destination: AnimeDetailsView()
								.environmentObject(AnimeDetailsViewModel(malId: anime.mal_id))
						)
						{
							VStack
							{
								Text(viewModel.displayTitle(for: anime))
									.font(.title)
									.foregroundColor(.primary)
								
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
									.frame(width: 300, height: 400)
								}
								
								if let episodes = anime.episodes
								{
									Text("Episodes: \(episodes)")
										.foregroundColor(.primary)
								}
								
								Text(anime.status)
									.foregroundColor(.primary)
								
								if let score = anime.score
								{
									Text("Score: \(String(format: "%.2f", score))/10")
										.foregroundColor(.primary)
								}
								
								Divider()
							}
							.padding(.horizontal, 8)
							.onAppear
							{
								if anime.mal_id == viewModel.animeList.last?.mal_id && viewModel.pagination!.has_next_page
								{
									Task
									{
										viewModel.page += 1
										await viewModel.fetchSearch()
									}
								}
							}
						}
					}
				}
				
				if viewModel.isLoading
				{
					ProgressView()
				}
			}
			else if let errorMessage = viewModel.errorMessage
			{
				CenteredContainer
				{
					Text(errorMessage)
						.foregroundColor(.red)
				}
			}
			else if !viewModel.searchQuery.isEmpty
			{
				CenteredContainer
				{
					if !viewModel.isLoading && viewModel.animeList.isEmpty
					{
						Text("No results found")
					}
					else
					{
						ProgressView("Loading")
					}
				}
			}
			else
			{
				CenteredContainer
				{
					Text("Search anime...")
				}
			}
		}
	}
}

#Preview
{
	AnimeSearchView()
		.environmentObject(AnimeSearchViewModel())
		.environmentObject(Settings())
}
