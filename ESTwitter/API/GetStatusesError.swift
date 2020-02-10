//
//  SearchError.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/02/10.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

public enum GetStatusesError : Error {

	case apiError(APIError)
	case parseError(String)
	case unexpected(Error)
	case unexpectedWithDescription(String)

	case genericError(String)
	case responseError(code: Int, message: String)

	// Specific Error
	
	case missingOrInvalidUrlParameter
}

extension GetStatusesError {
	
	init(tweetError error: SwifterError) {
		
		switch error.kind {
			
		case .urlResponseError:
			
			switch SwifterError.Response(fromMessage: error.message) {
				
			case .some(let response) where response.code == 195:
				self = .missingOrInvalidUrlParameter
				
			case .some(let response):
				self = .responseError(code: response.code, message: response.message)
				
			case .none:
				self = .genericError(error.message)
			}
			
		default:
			self = .genericError(error.message)
		}
	}
}
