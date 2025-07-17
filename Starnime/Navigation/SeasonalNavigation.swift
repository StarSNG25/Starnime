//
//  SeasonalNavigation.swift
//  Starnime
//
//  Created by Star_SNG on 2025/07/17.
//

import Foundation

public enum SeasonalNavigationDestination: Hashable
{
	case settings
	case search
	case details(malId: Int)
}
