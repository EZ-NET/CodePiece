//
//  AboutWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim

public class AboutWindowController: NSWindowController {

    public override func windowDidLoad() {
        super.windowDidLoad()

		// FIXME: 😨 リサイズさせたくないのですが IB でリサイズを無効化してもできてしまいます。コードでマスクを操作してみましたが、それでも効果がないようでした。メニューからストーリーボードで直接インスタンス化しているのが問題なのかもしれません。
		self.window!.styleMask.modifyMask(reset: NSResizableWindowMask)
    }

	public static func instantiate() -> AboutWindowController {
		
		let storyboard = NSStoryboard(name: "AboutWindowController", bundle: nil)
		
		return self.instantiate(storyboard)!
	}
	
	public static func instantiate(storyboard:NSStoryboard, identifier:String? = nil) -> AboutWindowController? {

		if let identifier = identifier {

			return storyboard.instantiateControllerWithIdentifier(identifier) as? AboutWindowController
		}
		else {
			
			return storyboard.instantiateInitialController() as? AboutWindowController
		}
	}

	public override var contentViewController: NSViewController? {
	
		get {
			
			return super.contentViewController
		}
		
		set {
			
			fatalError("Not supported.")
		}
	}
	
	public var aboutViewController: AboutViewController {
	
		return super.contentViewController as! AboutViewController
	}
	
	public var acknowledgementsName:String? {
		
		didSet {
			
			self.aboutViewController.acknowledgementsName = self.acknowledgementsName
		}
	}
	
	public var hasAcnowledgements:Bool {
		
		return self.acknowledgementsName != nil
	}
	
	public func showWindow() {
		
		self.showWindow(self)
	}
}
