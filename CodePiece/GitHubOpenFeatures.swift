//
//  GitHubOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Ocean

@objcMembers
final class GitHubOpenFeatures : NSObject, AlertDisplayable, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	override init() {
		
		super.init()
		
		observe(Authorization.GistAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			withChangeValue(for: "canOpenGitHubHome")
		}
	}
	
	var canOpenGitHubHome:Bool {
		
		guard NSApp.isReadyForUse else {
			
			return false
		}

		return NSApp.settings.account.authorizationState.isValid
	}
	
	@IBAction func openGitHubHomeAction(_ sender:AnyObject) {
	
		openGitHubHome()
	}
	
	func openGitHubHome() {
		
		guard let username = NSApp.settings.account.username else {
			
			return showErrorAlert(withTitle: "Failed to open GitHub", message: "GitHub user is not set.")
		}
		
		let urlString = "https://GitHub.com/\(username)"
		
		guard let url = URL(string: urlString) else {
			
			return showErrorAlert(withTitle: "Failed to open GitHub", message: "Invalid URL '\(urlString)'.")
		}
		
		NSWorkspace.shared.open(url).isFalse {
			
			showErrorAlert(withTitle: "Failed to open GitHub", message: "URL '\(url)' cannot open.")
		}
	}
}
