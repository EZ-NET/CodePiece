//
//  CodeTextView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import CodePieceCore

@objcMembers
final class CodeTextView: NSTextView {

}

extension CodeTextView : CodeTextType {
	
	var code: Code {

		return Code(string)
	}
	
	func clearCodeText() {
		
		string = ""
	}
}
