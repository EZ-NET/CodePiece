//
//  ReachabilityController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/17.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Reachability

extension StatusImageView.Status {

	init(reachabilityState: ReachabilityController.State) {
		
		switch reachabilityState {
			
		case .viaWiFi:
			self = .Available
			
		case .viaCellular:
			self = .Available
			
		case .unreachable:
			self = .Unavailable
		}
	}
}

final class ReachabilityController {

	private var notificationHandler: HandlerID!
	
	private let reachability:Reachability!
	
	enum State {
		
		case viaWiFi
		case viaCellular
		case unreachable
		
		init(_ rawState: Reachability.Connection) {
			
			switch rawState {
				
			case .wifi:
				self = .viaWiFi
				
			case .cellular:
				self = .viaCellular
				
			case .unavailable, .none:
				self = .unreachable
			}
		}
	}
	
	final class ReachabilityChangedNotification : NotificationProtocol {
		
		private(set) var state:State
		
		init(_ state:State) {
			
			self.state = state
		}
	}

	/// - throws: ReachabilityError
	init() throws {
		
		do {
			
			self.reachability = try Reachability.reachabilityForInternetConnection()
		}
		catch {
			
			self.reachability = nil
			throw error
		}
		
		self.notificationHandler = NamedNotification.observe(ReachabilitySwift.ReachabilityChangedNotification, handler: reachabilityDidChange)
		
		try self.reachability.startNotifier()
	}
	
	deinit {
		
		self.notificationHandler.release()
	}
	
	var state:State {
		
		return State(reachability.connection)
	}
	
	func reachabilityDidChange(notification:NamedNotification) {
		
		guard notification.object === self.reachability else {
			
			fatalError("Reachability notification posted with unknown reachability object (\(notification.object))")
		}

		ReachabilityChangedNotification(self.state).post()
	}
}

extension ReachabilityController.State : CustomStringConvertible {

	var description:String {
		
		switch self {
			
		case .viaWiFi:
			return "Wi-Fi"
			
		case .viaCellular:
			return "Cellular"
			
		case .unreachable:
			return "Unreachable"
		}
	}
}
