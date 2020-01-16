//
//  Extension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

// 将来的に別のモジュールへ移動できそうな機能を実装しています。

import APIKit
import AppKit
import Ocean
import Swim
import Sky
import Dispatch

public var OutputStream = StandardOutputStream()
public var ErrorStream = StandardErrorStream()
public var NullStream = NullOutputStream()

// NOTE: 🐬 CodePiece の Data を扱うときに HTMLText を介すると attributedText の実装が逆に複雑化する可能性があるため、一旦保留にします。
//public struct HTMLText {
//
//	public var source: String
//	public var encoding: NSStringEncoding
//	
//	public init(source: String, encoding: NSStringEncoding = NSUTF8StringEncoding) {
//		
//		self.source = source
//		self.encoding = encoding
//	}
//
//	public var html: NSData {
//		
//		return source.dataUsingEncoding(NSUTF16StringEncoding, allowLossyConversion: true)!
//	}
//	
//	public var attributedText: NSAttributedString {
//		
////		let options: [String:AnyObject] = [NSFontAttributeName:NSFont(name: "SourceHanCodeJP-Regular", size: 13.0)!]
//		
////		return NSAttributedString(string: source)
//		return NSAttributedString(HTML: html, options: [:], documentAttributes: nil)!
//	}
//}
//
//extension HTMLText : StringLiteralConvertible {
//
//	public init(stringLiteral value: String) {
//
//		self.init(source: value)
//	}
//
//	public init(extendedGraphemeClusterLiteral value: String) {
//		
//		self.init(source: value)
//	}
//	
//	public init(unicodeScalarLiteral value: String) {
//
//		self.init(source: value)
//	}
//}
//
//extension HTMLText : RawRepresentable {
//	
//	public init(rawValue: String) {
//		
//		self.init(source: rawValue, encoding: NSUTF8StringEncoding)
//	}
//	
//	public var rawValue: String {
//		
//		return source
//	}
//}

extension NSIndexSet {

	public convenience init<S: Sequence>(sequence s: S) where S.Element == Int {
		
        let indexes = s.reduce(NSMutableIndexSet()) { $0.add($1); return $0 }
		
		self.init(indexSet: (indexes.copy() as! NSIndexSet) as IndexSet)
	}
}

extension NSIndexSet {
	
	public var isEmpty: Bool {
		
		return count == 0
	}
}

extension NSTableView {

	func topObjectsInRegisteredNibByIdentifier(identifier: String) -> [AnyObject]? {
		
		guard let nib = self.registeredNibsByIdentifier![identifier] else {
			
			return nil
		}
		
		var topObjects = NSArray?()
		
		guard nib.instantiateWithOwner(nil, topLevelObjects: &topObjects) else {
			
			fatalError("Failed to load nib '\(nib)'.")
		}
		
		return (topObjects as! [AnyObject])
	}
}

extension Date {

	var displayString: String {
		
        let calendar = NSCalendar.current
        let formatter = DateFormatter()
		
		formatter.calendar = calendar
		formatter.dateStyle = .short
		formatter.timeStyle = .medium
		
        return formatter.string(from: self)
	}
}

public func bundle<First,Second>(first: First) -> (Second) -> (First, Second) {

	return { second in (first, second) }
}

public func bundle<First,Second>(first: First, second: Second) -> (First, Second) {
	
	return (first, second)
}

func mask(mask:Int, reset values:Int...) -> Int {
	
	return values.reduce(mask) { $0 & ~$1 }
}

func mask( mask: inout Int, reset values: Int...) {
	
	values.forEach { mask = mask & ~$0 }
}

protocol MaskOperatable {
	
	func masked(reset values:Self...) -> Self
	func masked(reset values:[Self]) -> Self
	func masked(set values:Self...) -> Self
	func masked(set values:[Self]) -> Self
	
	mutating func modifyMask(reset values:Self...)
	mutating func modifyMask(reset values:[Self])
	mutating func modifyMask(set values:Self...)
	mutating func modifyMask(set values:[Self])
}

extension MaskOperatable {
	
	func masked(reset values:Self...) -> Self {
		
		return self.masked(reset: values)
	}
	
	func masked(set values:Self...) -> Self {
		
		return self.masked(set: values)
	}
	
	mutating func modifyMask(reset values:Self...) {
		
		self.modifyMask(reset: values)
	}
	
	mutating func modifyMask(reset values:[Self]) {
		
		for value in values {
			
			self = self.masked(reset: value)
		}
	}
	
	mutating func modifyMask(set values:Self...) {
		
		self.modifyMask(set: values)
	}
	
	mutating func modifyMask(set values:[Self]) {
		
		for value in values {
			
			self = self.masked(set: value)
		}
	}
}

extension Int : MaskOperatable {
	
	func masked(reset values: [Int]) -> Int {
		
		return values.reduce(self) { $0 & ~$1 }
	}
	
	func masked(set values: [Int]) -> Int {
		
		return values.reduce(self) { $0 | $1 }
	}
}

public class Semaphore : RawRepresentable {

	public enum WaitResult {
	
		case Success
		case Timeout
	}
	
	public struct Time : RawRepresentable {
	
		public var rawValue: dispatch_time_t
		
		public init() {
            
			self.rawValue = DISPATCH_TIME_NOW
		}
		
		public init(rawValue time:dispatch_time_t) {
			
			self.rawValue = time
		}
		
		public func delta(second time:Double) -> Time {
			
			return Time(rawValue: dispatch_time(self.rawValue, Interval(second: time).rawValue))
		}
		
		public func delta(millisecond time:Double) -> Time {
		
			return Time(rawValue: dispatch_time(self.rawValue, Interval(millisecond: time).rawValue))
		}
		
		public func delta(microsecond time:Double) -> Time {
			
			return Time(rawValue: dispatch_time(self.rawValue, Interval(microsecond: time).rawValue))
		}
		
		public func delta(nanosecond time:Int64) -> Time {
			
			return Time(rawValue: dispatch_time(self.rawValue, Interval(nanosecond: time).rawValue))
		}
	}
	
	public struct Interval : RawRepresentable {
		
		public var rawValue:Int64
		
		public init(second delta:Double) {
			
			self.rawValue = Int64(delta * NSEC_PER_SEC.toDouble())
		}
		
		public init(millisecond delta:Double) {
			
			self.rawValue = Int64(delta * NSEC_PER_MSEC.toDouble())
		}
		
		public init(microsecond delta:Double) {
			
			self.rawValue = Int64(delta * NSEC_PER_USEC.toDouble())
		}
		
		public init(nanosecond delta:Int64) {
			
			self.rawValue = delta
		}
		
		public init(rawValue:Int64) {
			
			self.rawValue = rawValue
		}
		
		public var second: Double {
			
			return self.rawValue.toDouble() / NSEC_PER_SEC.toDouble()
		}
		
		public var millisecond: Double {
			
			return self.rawValue.toDouble() / NSEC_PER_MSEC.toDouble()
		}
		
		public var microsecond: Double {
			
			return self.rawValue.toDouble() / NSEC_PER_USEC.toDouble()
		}
		
		public var nanosecond: Int64 {
			
			return self.rawValue
		}
	}
	
	private var semaphore:dispatch_semaphore_t
	
	public init(value:Int = 1) {
		
		self.semaphore = dispatch_semaphore_create(value)
	}
	
	public required init(rawValue semaphore: dispatch_semaphore_t) {
		
		self.semaphore = semaphore
	}
	
	public var rawValue:dispatch_semaphore_t {
		
		return self.semaphore
	}
	
	public func wait() {
		
		self.waitWithTimeout(Time())
	}
	
	public func waitWithTimeout(timeout:dispatch_time_t) -> WaitResult {
		
		switch dispatch_semaphore_wait(self.semaphore, timeout) {
			
		case 0:
			return .Success
			
		default:
			return .Timeout
		}
	}
	
	public func waitWithTimeout(timeout:Time) -> WaitResult {

		return self.waitWithTimeout(timeout.rawValue)
	}
	
	public func signal() {
		
		dispatch_semaphore_signal(self.semaphore)
	}
	
	public func execute(timeout:Time = Time(), body:() throws -> Void) rethrows -> WaitResult {
		
		return try self.execute(timeout.rawValue, body: body)
	}

	public func execute(timeout:dispatch_time_t = DISPATCH_TIME_FOREVER, body:() throws ->Void) rethrows -> WaitResult {

		switch self.waitWithTimeout(timeout) {
			
		case .Success:
		
			defer {
			
				self.signal()
			}
		
			try body()
		
			return .Success
			
		case .Timeout:
		
			return .Timeout
		}
	}
	
	public func executeOnQueue(queue:dispatch_queue_t, timeout:Time, body:(WaitResult) -> Void) {
		
		self.executeOnQueue(queue, timeout: timeout.rawValue, body: body)
	}
	
	public func executeOnQueue(queue:dispatch_queue_t, timeout:dispatch_time_t = DISPATCH_TIME_FOREVER, body:(WaitResult) -> Void) {
		
		dispatch_async(queue) {
			
			switch self.waitWithTimeout(timeout) {
				
			case .Success:
				
				defer {
					
					self.signal()
				}
				
				body(.Success)
				
				
			case .Timeout:
			
				body(.Timeout)
			}
		}
	}
}

extension Semaphore.Interval : CustomStringConvertible {

	public var description: String {
		
		return "\(self.second)"
	}
}

public protocol UnsignedIntegerConvertible {

	func toUInt() -> UInt
}

extension UIntMax {
	
	public init<T:UIntMaxConvertible>(_ value:T) {
		
		self = value.toUIntMax()
	}
}

extension Semaphore.Interval : UIntMaxConvertible {
	
	public init(_ value:UIntMax) {
	
		self.init(rawValue: value.toIntMax())
	}
	
	public func toUIntMax() -> UIntMax {
		
		return self.rawValue.toUIntMax()
	}
}

public final class Dispatch {
		
	public static func makeTimer(interval: UInt64, queue: dispatch_queue_t, start:Bool, eventHandler:dispatch_block_t) -> dispatch_source_t {
		
		return self.makeTimer(interval, queue: queue, start: start, eventHandler: eventHandler, cancelHandler: nil)
	}
	
	public static func makeTimer(interval: UInt64, queue: dispatch_queue_t, start:Bool, eventHandler:dispatch_block_t, cancelHandler: dispatch_block_t?) -> dispatch_source_t {
		
		let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
		
		source.setEventHandler(eventHandler)
		
		if let cancelHandler = cancelHandler {
			
			source.setCancelHandler(cancelHandler)
		}
		
		source.setTimer(interval)
		
		if start {
			
			source.resume()
		}
		
		return source
	}
}

extension dispatch_source_t {
	
	public func resume() {
		
		return dispatch_resume(self)
	}
	
	public func suspend() {
		
		return dispatch_suspend(self)
	}
	
	public func sourceCancel() {
		
		return dispatch_source_cancel(self)
	}
	
	public func setEventHandler(handler:dispatch_block_t) {
		
		return dispatch_source_set_event_handler(self, handler)
	}
	
	public func setCancelHandler(handler:dispatch_block_t) {
		
		return dispatch_source_set_cancel_handler(self, handler)
	}
	
	public func setTimer(interval: UInt64, start: dispatch_time_t = DISPATCH_TIME_NOW, leeway: UInt64 = 0) {
		
		return dispatch_source_set_timer(self, start, interval, leeway)
	}
}

internal enum MessageQueueHandler<Message : MessageType> {

	typealias Queue = MessageQueue<Message>
	typealias MessageHandler = Queue.MessageHandler
	typealias MessageErrorHandler = Queue.MessageErrorHandler?
	
	case Closure(messageHandler: MessageHandler, errorHandler: MessageErrorHandler)
	case Delegate(handler: _MessageQueueHandlerProtocol)
	
	func handlingMessage(message: Message, byQueue queue:Queue) throws {
		
		switch self {
			
		case let .Closure(messageHandler: handler, errorHandler: _):
			try handler(message)
			
		case let .Delegate(handler):
			try handler._messageQueue(queue, handlingMessage: message)
		}
	}
	
	func handlingError(error: Error, byQueue queue:Queue) throws {
		
		switch self {

		case let .Closure(messageHandler: _, errorHandler: handler):
			try handler?(error)
			
		case let .Delegate(handler):
			try handler._messageQueue(queue, handlingError: error)
		}
	}
}

public protocol MessageQueueType : AnyObject {
	
	associatedtype Message : MessageType
}

public protocol MessageType {
	
	/// Call when the message send completely.
	func messageQueued()
	
	/// Call when the message blocked.
	func messageBlocked()
}

extension MessageType {
	
	/// Call when the message send completely.
	public func messageQueued() {
		
	}
	
	/// Call when the message blocked.
	public func messageBlocked() {
		
	}
}

public protocol PreActionMessageType : MessageType {
	
	func messagePreAction(queue:Queue<Self>) -> Continuous
}

public protocol MessageTypeIgnoreInQuickSuccession : PreActionMessageType {
	
	/// Returns true if the message may block in quick succession.
	var mayBlockInQuickSuccession:Bool { get }
	
	func blockInQuickSuccession(lastMessage:Self) -> Bool
}

extension MessageTypeIgnoreInQuickSuccession {
	
	public var mayBlockInQuickSuccession:Bool {
		
		return true
	}
	
	public func messagePreAction(queue:Queue<Self>) -> Continuous {
		
		guard self.mayBlockInQuickSuccession else {
		
			return .continue
		}
		
        if let lastMessage = queue.back, self.blockInQuickSuccession(lastMessage: lastMessage) {
			
			return .abort
		}
		else {
			
			return .continue
		}
	}
}

extension MessageTypeIgnoreInQuickSuccession where Self : Equatable {
	
	public func blockInQuickSuccession(lastMessage:Self) -> Bool {
		
		return self == lastMessage
	}
}

private let MessageQueueDefaultProcessingInterval:Double = 0.03

public class MessageQueue<M:MessageType> : MessageQueueType {
	
	public typealias Message = M
	public typealias MessageErrorHandler = (Error) throws -> Void
	public typealias MessageHandler = (Message) throws -> Void
	public typealias MessageHandlerNoThrows = (Message) -> Void
	
	private(set) var identifier:String
	
	private var handler:MessageQueueHandler<Message>
	private var messageQueue:Queue<Message>
	
	private var messageProcessingQueue: DispatchQueue
	private var messageHandlerExecutionQueue: DispatchQueue
	private var messageLoopSource:dispatch_source_t!
	
	public private(set) var isRunning:Bool

	internal init(identifier:String, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueueDefaultProcessingInterval, handler:MessageQueueHandler<Message>) {
		
		self.identifier = identifier
		self.handler = handler
		
		let queue = DispatchQueue(identifier: "\(identifier)", nil)
		
		self.messageProcessingQueue = queue
		self.messageHandlerExecutionQueue = executionQueue ?? queue
		
		self.messageQueue = []
		self.isRunning = false

		self.messageLoopSource = self.makeTimer(Semaphore.Interval(second: processingInterval), start: true, timerAction: _messageLoopBody)
	}

	public convenience init(identifier:String, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueueDefaultProcessingInterval, messageHandler:MessageHandler, errorHandler:MessageErrorHandler?) {

		let handler = MessageQueueHandler.Closure(messageHandler: messageHandler, errorHandler: errorHandler)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}

	public convenience init(identifier:String, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueueDefaultProcessingInterval, messageHandler:MessageHandlerNoThrows) {
		
		let handler = MessageQueueHandler.Closure(messageHandler: messageHandler, errorHandler: nil)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}
	
	public convenience init<T:_MessageQueueHandlerProtocol>(identifier:String, handler:T, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueueDefaultProcessingInterval) {
		
		let handler = MessageQueueHandler<Message>.Delegate(handler: handler)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}
	
	deinit {
		
		self._stopMessageLoop()
		self.messageLoopSource.sourceCancel()
	}

	public func makeTimer(interval: Semaphore.Interval, start: Bool, timerAction: () -> Void) -> dispatch_source_t {

		return Dispatch.makeTimer(interval.toUIntMax(), queue: self.messageProcessingQueue, start: start, eventHandler: timerAction)
	}

	public func makeTimer(interval: Semaphore.Interval, start: Bool, timerAction: () -> Void, cancelAction: () -> Void) -> dispatch_source_t {
	
		return Dispatch.makeTimer(interval.toUIntMax(), queue: self.messageProcessingQueue, start: start, eventHandler: timerAction, cancelHandler: cancelAction)
	}
	
	public func start() {
	
		self.send(.Start)
	}
	
	public func stop() {
		
		self.send(.Stop)
	}
	
	public func send(message: MessageQueueControl) {
		
		self.executeOnProcessingQueue {

			switch message {
				
			case .Start:
				self._startMessageLoop()
				
			case .Stop:
				self._stopMessageLoop()
			}
		}
	}
	
	public func send(message: Message, preAction:(Queue<Message>, Message) -> Continuous) {
		
		self.executeOnProcessingQueue {

			guard preAction(self.messageQueue, message) else {
		
				message.messageBlocked()
				return
			}
			
			self.messageQueue.enqueue(message)
			message.messageQueued()
		}
	}
}

extension MessageQueue where M : MessageType {
	
	public func send(message: Message) {
		
		self.send(message) { (queue, message) -> Continuous in .continue }
	}
	
	public func sendContinuously(message: Message, interval:Semaphore.Interval) -> dispatch_source_t {
		
		return self.makeTimer(interval, start: true) { [weak self] () -> Void in
			
			self?.send(message)
		}
	}
}

extension MessageQueue where M : PreActionMessageType {
	
	public func send(message: Message) {
		
        self.send(message: message) { (queue, message) -> Continuous in
			
            return message.messagePreAction(queue: queue)
		}
	}
	
	public func sendContinuously(message: Message, interval:Semaphore.Interval) -> dispatch_source_t {
		
		return self.makeTimer(interval, start: true) { [weak self] () -> Void in
			
			self?.send(message)
		}
	}
}

/// If you want to manage queue handlers using Cocoa style,
/// let conforms to the protocol, then the instance pass to MessageQueue's initializer.
public protocol _MessageQueueHandlerProtocol {
	
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingMessage:Queue.Message) throws
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingError:Error) throws
}

public protocol MessageQueueHandlerProtocol : _MessageQueueHandlerProtocol {
	
	associatedtype Message : MessageType

	func messageQueue(queue:MessageQueue<Message>, handlingMessage:Message) throws
	func messageQueue(queue:MessageQueue<Message>, handlingError:Error) throws
}

extension MessageQueueHandlerProtocol {
	
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingMessage message:Queue.Message) throws {

		let queue = queue as! MessageQueue<Message>
		let message = message as! Message
		
        try self.messageQueue(queue: queue, handlingMessage: message)
	}
	
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingError error:Error) throws {
		
		let queue = queue as! MessageQueue<Message>
		
        try self.messageQueue(queue: queue, handlingError: error)
	}
}

public enum MessageQueueControl {
	
	case Start
	case Stop
}

extension MessageQueue {

	public func executeSyncOnProcessingQueue<R>(execute:()->R) -> R {

		return invoke(self.messageProcessingQueue, predicate: execute)
	}

	public func executeOnProcessingQueue(execute:dispatch_block_t) {
		
		invokeAsync(self.messageProcessingQueue, predicate: execute)
	}
	
	public func executeSyncOnHandlerExecutionQueue<R>(execute:()->R) -> R {
		
		return invoke(self.messageHandlerExecutionQueue, predicate: execute)
	}
	
	public func executeOnHandlerExecutionQueue(execute:dispatch_block_t) {
		
		invokeAsync(self.messageHandlerExecutionQueue, predicate: execute)
	}
	
	func _startMessageLoop() {

		self.isRunning = true
	}
	
	func _stopMessageLoop() {

		self.isRunning = false
	}

	func _messageLoopBody() {
	
		guard self.isRunning else {
			
			return
		}
		
		guard let message = self.messageQueue.dequeue() else {
			
			return
		}
		
		let handler = self.handler
		
		self.executeOnHandlerExecutionQueue {

			func executeErrorHandlerIfNeeds(error:Error) {
				
				do {
					
					try handler.handlingError(error, byQueue: self)
				}
				catch {
					
					fatalError("An error occurred during executing message handler. \(error)")
				}
			}
			
			do {
				
				try handler.handlingMessage(message, byQueue: self)
			}
			catch {

				executeErrorHandlerIfNeeds(error)
			}
		}
	}
}

public struct Repeater<Element> : Sequence {

	private var generator:RepeaterGenerator<Element>
	
	public init(_ value:Element) {
		
		self.init { value }
	}
	
	public init (_ generate:()->Element) {
		
		self.generator = RepeaterGenerator(generate)
	}
	
	public func generate() -> RepeaterGenerator<Element> {
		
		return self.generator
	}
	
	public func zipLeftOf<S:Sequence>(s:S) -> Zip2Sequence<Repeater,S> {
		
		return zip(self, s)
	}
	
	public func zipRightOf<S:Sequence>(s:S) -> Zip2Sequence<S,Repeater> {
		
		return zip(s, self)
	}
}

public struct RepeaterGenerator<Element> : IteratorProtocol {
	
	private var _generate:()->Element
	
	init(_ value:Element) {
		
		self.init { value }
	}
	
    init (_ generate: @escaping ()->Element) {
		
		self._generate = generate
	}
	
	public func next() -> Element? {
		
		return self._generate()
	}
}


public protocol Selectable : AnyObject {
	
	var selected:Bool { get set }
}

extension Selectable {
	
	public static func selected(instance:Self) -> () -> Bool {
		
		return { instance.selected }
	}
	
	public static func setSelected(instance:Self) -> (Bool) -> Void {
		
		return { instance.selected = $0 }
	}
}

extension Sequence where Element : Selectable {

	public mutating func selectAll() {
		
		self.forEach { $0.selected = true }
	}
	
	public mutating func deselectAll() {
		
		self.forEach { $0.selected = false }
	}
}

extension Sequence where Element : AnyObject {
	
	public var selectableElementsOnly:[Selectable] {
		
		return self.map { $0 as? Selectable }.flatMap { $0 }
	}
}


extension Optional {

	public func ifHasValue(predicate:(Wrapped) throws -> Void) rethrows {
		
		if case let value? = self {
			
			try predicate(value)
		}
	}
}

extension Bool {

	public func isTrue(predicate:() throws -> Void) rethrows {
		
		if self {
			
			try predicate()
		}
	}
	
	public func isFalse(predicate:() throws -> Void) rethrows {
		
		if !self {
			
			try predicate()
		}
	}
}

public class StandardOutputStream : OutputStream {
	
	public func write(string: String) {
		
		print(string)
	}
}

public class StandardErrorStream : OutputStream {
	
	public func write(string: String) {
		
		debugPrint(string)
	}
}

public class NullOutputStream : OutputStream {
	
	public func write(string: String) {
		
	}
}

extension Optional {
	
	public func invokeIfExists(expression:(Wrapped) throws -> Void) rethrows -> Void {
		
		if let value = self {

			try expression(value)
		}
	}
}

public func whether(condition: @autoclosure () throws -> Bool) rethrows -> YesNoState {
	
	return try condition() ? .Yes : .No
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError(expression: @autoclosure () throws -> Void) -> Void {
	
    handleError(expression: expression(), to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError<R>(expression: @autoclosure () throws -> R) -> R? {

    return handleError(expression: expression(), to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<STREAM: OutputStream>(expression: @autoclosure () throws -> Void, to stream: inout STREAM) -> Void {
	
	handleError(expression) { (error:Error)->Void in
		
        stream.write("Error Handling: \(error)", maxLength: Int.max)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R,STREAM: OutputStream>(expression: @autoclosure () throws -> R, to stream: inout STREAM) -> R? {
	
	return handleError(expression) { (error: Error)->Void in
		
		stream.write("Error Handling: \(error)", maxLength: Int.max)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError(expression: @autoclosure () throws -> Void, by handler:(Error)->Void) -> Void {
	
	do {
		
		try expression()
	}
	catch {
		
		handler(error)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R>(expression: @autoclosure () throws -> R, by handler:(Error)->Void) -> R? {
	
	do {
		
		return try expression()
	}
	catch {
		
		handler(error)
		
		return nil
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<E:Error>(expression: @autoclosure () throws -> Void, by handler:(E)->Void) -> Void {
	
	do {
		
		try expression()
	}
	catch let error as E {
		
		handler(error)
	}
	catch {
		
		fatalError("Unexpected Error: \(error)")
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R,E:Error>(expression: @autoclosure () throws -> R, by handler:(E)->Void) -> R? {
	
	do {
		
		return try expression()
	}
	catch let error as E {
		
		handler(error)
		
		return nil
	}
	catch {
		
		fatalError("Unexpected Error: \(error)")
	}
}

public protocol KeyValueChangeable {

	func withChangeValue(for keys: String...)
	func withChangeValue(for keys: String..., body: () -> Void)
	func withChangeValue<S: Sequence>(for keys: S, body: () -> Void)  where S.Element == String
}

// FIXME: Xcode 7.3.1 からか、なぜか NSObject だけでなく NSViewController にも　KeyValueChangeable を適用しないと、その先で準拠性を約束できませんでした。
extension NSViewController : KeyValueChangeable {
}

extension NSObject : KeyValueChangeable {

	public func withChangeValue(for keys: String...) {
		
		withChangeValue(for: keys, body: {})
	}

	public func withChangeValue(for keys: String..., body: () -> Void) {

		withChangeValue(for: keys, body: body)
	}

	public func withChangeValue<S: Sequence>(for keys: S, body: () -> Void) where S.Element == String {
		
		keys.forEach(willChangeValue)
		
		defer {
			
			keys.forEach(didChangeValue)
		}
		
		body()
	}
}

public class ObjectKeeper<T:AnyObject> {

	public private(set) var instance:T?
	
	public init(_ instance:T) {

		self.instance = instance
	}
	
	public func release() {
		
		self.instance = nil
	}
}

public extension NSAppleEventDescriptor {
	
	var url: NSURL? {
		
		paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue.flatMap { NSURL(string: $0) }
	}
}

public final class DebugTime {

	public static func print(_ message:String) {

		#if DEBUG
		NSLog("\(message)")
		#endif
	}
}

public protocol AcknowledgementsIncluded {

	var acknowledgementsName:String! { get }
	var acknowledgementsBundle:Bundle? { get }
}

public protocol AcknowledgementsIncludedAndCustomizable : AcknowledgementsIncluded {
	
	var acknowledgementsName:String! { get set }
	var acknowledgementsBundle:Bundle? { get set }
}

extension AcknowledgementsIncluded {

	var acknowledgementsBundle:Bundle? {

		return nil
	}
	
	var acknowledgements:Acknowledgements {

		return Acknowledgements(name: self.acknowledgementsName, bundle: self.acknowledgementsBundle)!
	}
}

/// Acknowledgements for CocoaPods.
public struct Acknowledgements {

	public struct Pod {
	
		public var name:String
		public var license:String
	}
	
	public var pods:[Pod]
	public var headerText:String
	public var footerText:String
	
	public init?(name:String, bundle:Bundle?) {
	
		let bundle = bundle ?? Bundle.main
		
        guard let path = bundle.path(forResource: name, ofType: "plist") else {
			
			return nil
		}
		
		guard let acknowledgements = NSDictionary(contentsOfFile: path) else {
			
			return nil
		}
		
		guard let items = acknowledgements["PreferenceSpecifiers"] as? Array<Dictionary<String, String>> else {
			
			return nil
		}
		
		guard items.count > 2 else {
			
			return nil
		}
		
		self.pods = [Pod]()
		
		let header = items.first!
		let footer = items.last!
		
		self.headerText = header["FooterText"]!
		self.footerText = footer["FooterText"]!
		
		for item in items[items.startIndex.successor() ..< items.endIndex.predecessor()] {
			
			let name = item["Title"]!
			let license = item["FooterText"]!
			
			self.pods.append(Pod(name: name, license: license))
		}
	}
}

extension Acknowledgements : CustomStringConvertible {
	
	public var description:String {
		
		var results = [String]()
		
		results.append(self.headerText)
		results.append("")
		
		for pod in self.pods {
			
			results.append("\(pod.name) : \(pod.license)")
		}
		
		results.append("")
		results.append(self.footerText)
		
        return results.joined(separator: "\n")
	}
}

// MARK: - Bundle

extension Bundle {
	
	public var appName:String? {
		
		let info = self.infoDictionary!
		
		if let name = info["CFBundleDisplayName"] as? String {
			
			return name
		}
		
		if let name = info["CFBundleName"] as? String {
			
			return name
		}
		
		return nil
	}
	
	public var appVersion:(main:String?, build:String?) {
		
		let info = self.infoDictionary!

		let main = info["CFBundleShortVersionString"] as? String
		let build = info["CFBundleVersion"] as? String
		
		return (main: main, build: build)
	}
	
	public var appCopyright:String? {
		
		return self.infoDictionary!["NSHumanReadableCopyright"] as? String
	}
	
	public var appVersionString:String {
		
		let version = self.appVersion
		
		let main = version.main ?? ""
		let build = version.build.map { "build \($0)" } ?? ""
		
        let value = main.appendStringIfNotEmpty(string: build, separator: " ")

		return value
	}
}

// MARK: - Thread

private func ~= (pattern:dispatch_queue_attr_t, value:dispatch_queue_attr_t) -> Bool {
	
	return pattern.isEqual(value)
}

public struct Thread {
	
	public enum `Type` : RawRepresentable {
		
		case Serial
		case Concurrent
		
		public init?(rawValue: dispatch_queue_attr_t!) {
			
			switch rawValue {
				
			case DISPATCH_QUEUE_CONCURRENT:
				self = .Concurrent
				
			case DISPATCH_QUEUE_SERIAL:
				self = .Serial
				
			default:
				return nil
			}
		}
		
		public var rawValue:dispatch_queue_attr_t! {
			
			switch self {
				
			case .Concurrent:
				return DISPATCH_QUEUE_CONCURRENT
				
			case .Serial:
				return DISPATCH_QUEUE_SERIAL
			}
		}
	}
	
	var queue: DispatchQueue
	
	public init(name: String, type: Type = .Serial) {

		queue = DispatchQueue(name, type.rawValue)
	}
	
	public func invokeAsync(predicate: @escaping () -> Void) {
		
		queue.async(execute: predicate)
	}
	
	public func invoke<Result>(predicate: () -> Result) -> Result {
		
		queue.sync(execute: predicate)
	}
}

// MARK: - Capture

protocol Captureable {
	
	associatedtype CaptureTarget
	
	var captureTarget:CaptureTarget { get }
	
	func capture() -> NSImage
}

extension Captureable where CaptureTarget == NSView {

	func capture() -> NSImage {
	
        return CodePiece.capture(view: self.captureTarget)
	}
	
	func capture(rect:NSRect) -> NSImage {
		
        return CodePiece.capture(view: self.captureTarget, rect: rect)
	}
}

extension Captureable where CaptureTarget == NSWindow {
	
	func capture() -> NSImage {
		
        return CodePiece.capture(window: self.captureTarget)
	}
}

extension NSView : Captureable {
	
	public var captureTarget:NSView {
		
		return self
	}
}

extension NSView : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return (self.window?.backingScaleFactor).map(Scale.init)
	}
}

extension NSWindow : Captureable {
	
	public var captureTarget:NSWindow {
		
		return self
	}
}

extension NSWindow : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return Scale(self.backingScaleFactor)
	}
}

extension NSApplication : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return self.keyWindow?.scale
	}
}

func capture(view:NSView) -> NSImage {

    return capture(view: view, rect: view.bounds)
}

func capture(view:NSView, rect:NSRect) -> NSImage {
	
    guard rect != .zero else {

		fatalError("Bounds is Zero.")
	}

	let viewRect = view.bounds
	
	// Retina が混在した環境ではどの画面でも、サイズ情報はそのまま、ピクセルが倍解像度で得られるようです。
	// imageRep や、ここから生成した NSImage に対する操作は scale を加味しない座標系で問題ありませんが、
	// CGImage に対する処理は、スケールを加味した座標指定が必要になるようです。
    let imageRep = view.bitmapImageRepForCachingDisplay(in: viewRect)!

    view.cacheDisplay(in: viewRect, to: imageRep)
	
    let cgImage = imageRep.cgImage!
    let cgImageScale = cgImage.widthScale(of: viewRect.size)
    let scaledRect = rect.scaled(by: cgImageScale).rounded()
	
	let clippedImage = CGImageCreateWithImageInRect(cgImage, scaledRect)!

    let image = NSImage(cgImage: clippedImage, size: scaledRect.size)

	// TODO: 画像の見やすさを考えて余白を作れたら良さそう。
	let horizontal = 0 // Int(max(image.size.height - image.size.width, 0) / 2.0)
	let vertical = 0 // Int(max(image.size.width - image.size.height, 0) / 2.0)
	
	let margin = Margin(vertical: vertical, horizontal: horizontal)
    let newImage = createImage(image: image, margin: margin)

	return newImage
}


//extension Margin where Type : IntegerArithmeticType {
//	
//	public var horizontalTotal:Type {
//		
//		return self.left + self.right
//	}
//	
//	public var verticalTotal:Type {
//		
//		return self.top + self.bottom
//	}
//}

public func createImage(image:NSImage, margin:IntMargin) -> NSImage {

	let newWidth = Int(image.size.width) + margin.horizontalTotal
	let newHeight = Int(image.size.height) + margin.verticalTotal
	
	let bitsPerComponent = 8
	let bytesPerRow = 4 * newWidth
	let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	
	let point = NSPoint(x: CGFloat(margin.left), y: CGFloat(margin.top))
	
    guard let bitmapContext = CGContext(data: nil, width: newWidth, height: newHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
		
		fatalError("Failed to create a bitmap context.")
	}
	
	
	let bitmapSize = NSSize(width: CGFloat(newWidth), height: CGFloat(newHeight))
	let bitmapRect = NSRect(origin: NSZeroPoint, size: NSSize(width: bitmapSize.width, height: bitmapSize.height))

    let graphicsContext = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
	
	NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphicsContext
	
	image.drawAtPoint(point, fromRect: bitmapRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)

	NSGraphicsContext.restoreGraphicsState()
	
    guard let newImageRef = bitmapContext.makeImage() else {
		
		fatalError("Failed to create a bitmap with margin.")
	}

    let newImage = NSImage(cgImage: newImageRef, size: bitmapSize)
	
	return newImage
}

func capture(window:NSWindow) -> NSImage {
	
	let windowId = CGWindowID(window.windowNumber)

    let imageRef = CGWindowListCreateImage(.zero, .optionIncludingWindow, windowId, [])
    let imageData = NSImage(cgImage: imageRef!, size: window.contentView!.bounds.size)
	
	return imageData
}

// MARK: - String

extension String {

	public func appendStringIfNotEmpty(string:String?, separator:String = "") -> String {
		
		guard let string = string, !string.isEmpty else {
			
			return self
		}
		
		return "\(self)\(separator)\(string)"
	}
}

extension APIError : CustomDebugStringConvertible {
	
	public var debugDescription:String {
		
		switch self {
			
		case ConnectionError(let error):
			return error.localizedDescription
			
		case InvalidBaseURL(let url):
			return "Invalid base URL (\(url))"
			
		case ConfigurationError(let error):
			return "Configuration error (\(error))"
			
		case RequestBodySerializationError(let error):
			return "Request body serialization error (\(error))"
			
		case UnacceptableStatusCode(let code, let error):
			return "Unacceptable status code \(code) (\(error))"
			
		case ResponseBodyDeserializationError(let error):
			return "Response body deserialization error (\(error))"
			
		case InvalidResponseStructure(let object):
			return "Invalid response structure (\(object))"
			
		case NotHTTPURLResponse(let response):
			return "Not HTTP URL Response (\(response))"
		}
	}
}
