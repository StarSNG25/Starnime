//
//  StringExtension.swift
//  Starnime
//
//  Created by Star_SNG on 2024/08/10.
//

import Foundation

extension String
{
	var capitalizedFirstLetter: String
	{
		return prefix(1).uppercased() + dropFirst()
	}
}
