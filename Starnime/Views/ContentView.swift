//
//  ContentView.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/08.
//

import SwiftUI

struct ContentView: View
{
	var body: some View
	{
		VStack
		{
			HStack
			{
				Image(systemName: "video")
				 .imageScale(.large)
				 .foregroundStyle(.tint)
			 Text("Starnime")
				 .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
			}
			Text("Private Anime List")
				.font(.subheadline)
		}
	}
}

#Preview
{
	ContentView()
}
