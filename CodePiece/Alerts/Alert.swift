//
//  Alert.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

protocol AlertDisplayable {

}

extension NSViewController : AlertDisplayable {
	
}

extension AlertDisplayable {

	func showInformationAlert(title:String, message:String) {
		
		self.dynamicType.showInformationAlert(title, message: message)
	}
	
	func showWarningAlert(title:String, message:String, debugDescription: String? = nil) {
		
		self.dynamicType.showWarningAlert(title, message: message, debugDescription: debugDescription)
	}
	
	func showErrorAlert(title:String, message:String, debugDescription: String? = nil) {
		
		self.dynamicType.showErrorAlert(title, message: message, debugDescription: debugDescription)
	}
	
	private static func showAlert(alert:NSAlert) {
	
		dispatch_async(dispatch_get_main_queue()) {
			
			alert.runModal()
		}
	}
	
	static func showInformationAlert(title:String, message:String) {
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("OK")
		alert.alertStyle = .InformationalAlertStyle
	
		self.showAlert(alert)
	}
	
	static func showWarningAlert(title:String, message:String, debugDescription: String? = nil) {
		
		NSLog("Warning: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("OK")
		alert.alertStyle = .WarningAlertStyle
		
		self.showAlert(alert)
	}
	
	static func showErrorAlert(title:String, message:String, debugDescription: String? = nil) {

		NSLog("Error: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("OK")
		alert.alertStyle = .CriticalAlertStyle

		self.showAlert(alert)
	}
}
