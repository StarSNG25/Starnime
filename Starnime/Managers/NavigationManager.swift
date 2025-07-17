//
//  NavigationManager.swift
//  Starnime
//
//  Created by Star_SNG on 2025/07/17.
//

import SwiftUI

@MainActor
class NavigationManager: ObservableObject
{
	@Published var path = NavigationPath()
}
