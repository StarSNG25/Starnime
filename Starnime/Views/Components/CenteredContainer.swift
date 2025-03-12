//
//  CenteredContainer.swift
//  Starnime
//
//  Created by Star_SNG on 2025/03/12.
//

import SwiftUI

struct CenteredContainer<Content: View>: View
{
	@ViewBuilder var content: Content
	
	var body: some View
	{
		ZStack
		{
			Spacer()
				.containerRelativeFrame([.horizontal, .vertical])
			content
		}
	}
}

#Preview
{
	CenteredContainer
	{
		ProgressView("Loading")
	}
}
