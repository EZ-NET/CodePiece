//
//  DebugTime.swift
//  CodePieceCore
//
//  Created by kumagai on 2020/05/26.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public final class DebugTime {

	public static func print(_ message: String) {

		#if DEBUG
		NSLog("%@", message)
		#endif
	}
}
