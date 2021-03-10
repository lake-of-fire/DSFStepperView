//
//  DSFStepperView+SwiftUI.swift
//
//  Created by Darren Ford on 13/11/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//
//	MIT License
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DSFStepperView {
	public struct SwiftUI: DSFViewRepresentable {
		#if os(macOS)
		public typealias NSViewType = DSFStepperView
		#else
		public typealias UIViewType = DSFStepperView
		#endif

		public typealias OnValueChangeType = ((CGFloat?) -> Void)

		public struct DisplaySettings {
			let minimum: CGFloat
			let maximum: CGFloat
			let increment: CGFloat

			let initialValue: CGFloat?
			var placeholderText: String?

			var numberFormatter: NumberFormatter?

			var allowsKeyboardInput = true

			let font: DSFFont?

			public init(
				minimum: CGFloat = -CGFloat.greatestFiniteMagnitude,
				maximum: CGFloat = CGFloat.greatestFiniteMagnitude,
				increment: CGFloat = 1,
				initialValue: CGFloat = 0,
				placeholderText: String? = nil,
				numberFormatter: NumberFormatter? = nil,
				allowsKeyboardInput: Bool = true,
				font: DSFFont? = nil
			) {
				self.minimum = minimum
				self.maximum = maximum
				self.increment = increment
				self.initialValue = initialValue
				self.placeholderText = placeholderText
				self.numberFormatter = numberFormatter
				self.allowsKeyboardInput = allowsKeyboardInput
				self.font = font
			}
		}

		/// The configuration for the stepper view
		public let configuration: DisplaySettings

		/// The enabled state for the control
		public var isEnabled: Bool = true

		/// The color to draw the central value
		public var foregroundColor: DSFColor? = nil

		/// The current value for the control
		@Binding public var floatValue: CGFloat?

		/// An optional change value callback
		public var onValueChange: OnValueChangeType? = nil

		/// Initializer
		public init(configuration: DisplaySettings,
						isEnabled: Bool = true,
						foregroundColor: DSFColor? = nil,
						floatValue: Binding<CGFloat?> = .constant(0),
						onValueChange: OnValueChangeType? = nil) {

			self.configuration = configuration
			self.isEnabled = isEnabled
			self.foregroundColor = foregroundColor
			self._floatValue = floatValue
			self.onValueChange = onValueChange
		}
	}
}

// MARK: - View Representable

@inlinable internal func updateIfNotEqual<T>(result: inout T, val: T) where T: Equatable {
	if result != val {
		result = val
	}
}

@available(OSX 10.15, iOS 13, tvOS 13, macCatalyst 13.1.0, *)
extension DSFStepperView.SwiftUI {
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}

@available(iOS 13, tvOS 13, macOS 9999, *)
extension DSFStepperView.SwiftUI {

	public func makeUIView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		stepper.setContentHuggingPriority(.defaultLow, for: .horizontal)
		stepper.setContentHuggingPriority(.defaultLow, for: .vertical)

		if let iv = configuration.initialValue {
			stepper.initialValue = iv
		}

		if let f = configuration.numberFormatter {
			stepper.numberFormatter = f
		}

		if let nsFont = configuration.font {
			stepper.font = nsFont
		}

		return stepper
	}

	public func updateUIView(_ uiView: DSFStepperView, context: Context) {
		uiView.delegate = context.coordinator
		self.updateView(uiView)
	}
}

@available(macOS 10.15, iOS 9999, tvOS 9999, *)
extension DSFStepperView.SwiftUI {
	public func makeNSView(context: Context) -> DSFStepperView {
		let stepper = DSFStepperView(frame: .zero)
		stepper.translatesAutoresizingMaskIntoConstraints = false

		if let iv = configuration.initialValue {
			stepper.initialValue = iv
		}

		if let f = configuration.numberFormatter {
			stepper.numberFormatter = f
		}

		stepper.isEnabled = self.isEnabled

		if let nsFont = configuration.font {
			stepper.font = nsFont
		}

		return stepper
	}

	public func updateNSView(_ nsView: DSFStepperView, context: Context) {
		nsView.delegate = context.coordinator
		self.updateView(nsView)
	}
}

@available(macOS 10.15, iOS 13, tvOS 13, macCatalyst 13, *)
extension DSFStepperView.SwiftUI {
	func updateView(_ view: DSFStepperView) {
		updateIfNotEqual(result: &view.minimum, val: configuration.minimum)
		updateIfNotEqual(result: &view.maximum, val: configuration.maximum)
		updateIfNotEqual(result: &view.increment, val: configuration.increment)
		updateIfNotEqual(result: &view.placeholder, val: configuration.placeholderText)
		updateIfNotEqual(result: &view.isEnabled, val: self.isEnabled)
		updateIfNotEqual(result: &view.allowsKeyboardInput, val: configuration.allowsKeyboardInput)
		if let f = self.foregroundColor {
			updateIfNotEqual(result: &view.foregroundColor, val: f)
		}

		if view.numberFormatter !== configuration.numberFormatter {
			if let f = configuration.numberFormatter {
				view.numberFormatter = f
			}
		}

		if let newFont = configuration.font {
			view.font = newFont
		}
		else {
			view.font = nil
		}

		if let f = self.floatValue {
			view.floatValue = NSNumber(value: Double(f))
		}
	}
}

// MARK: - Coordinator

@available(macOS 10.15, macCatalyst 13.1.0, *)
extension DSFStepperView.SwiftUI {
	public class Coordinator: NSObject, DSFStepperViewDelegateProtocol {
		let parent: DSFStepperView.SwiftUI

		var previousValue: CGFloat? = nil

		init(_ stepper: DSFStepperView.SwiftUI) {
			self.parent = stepper
		}

		public func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
			var newValue: CGFloat? = nil

			if let v = value?.floatValue {
				newValue = CGFloat(v)
			}

			if self.previousValue == newValue {
				return
			}
			self.previousValue = newValue

			DispatchQueue.main.async { [weak self] in
				if let parent = self?.parent {
					parent.floatValue = newValue
					parent.onValueChange?(newValue)
				}
			}
		}
	}
}

#endif
