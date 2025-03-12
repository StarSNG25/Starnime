//
//  ErrorMessageView.swift
//  Starnime
//
//  Created by Star_SNG on 2025/03/12.
//

import SwiftUI

struct ErrorMessageView: View
{
	let errorMessage: String
	
	var body: some View
	{
		CenteredContainer
		{
			if errorMessage == "cancelled"
			{
				ProgressView("Loading")
			}
			else
			{
				Text(errorMessage)
					.foregroundColor(.red)
			}
		}
	}
}

#Preview
{
	ErrorMessageView(errorMessage: "エラー")
}
