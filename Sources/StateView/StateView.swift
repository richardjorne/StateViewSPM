//
//  StateView.swift
//  StateView
//
//  Created by Richard Jorne on 2024/5/6.
//

import SwiftUI
import Combine


public struct StateView<Content: View>: View {
    @State private var set: Bool = false
//    @State private var noAction: Bool = false
    
    ///  You provide this Binding to the real state you need.
    @Binding var setted: Bool
    
    ///  You provide this ViewBuilder to create the view that represents the state, i.e. a toggle.
    @ViewBuilder var stateContentView: (_ shownState: Binding<Bool>, _ actualState: Binding<Bool>, _ syncPresent: @escaping () -> Void) -> Content
    ///  You provide this function to do things that needs to be implemented to complete settings (to turn on the toggle).
    var setFunction: (_ syncPresent: @escaping () -> Void) -> Void
    ///  You provide this function to do things that needs to be implemented to turn off the toggle.
    var unsetFunction: (_ syncPresent: @escaping () -> Void) -> Void
    
    /// Initialize `StateView` to handle async states between displayed state and actual state in an elegant way.
    ///
    /// Usage:
    ///
    ///     StateView(actualState: $developerModeOn) { shownState, actualState, syncPresent in
    ///         Toggle(isOn: shownState, label: {
    ///             Text("Developer Mode")
    ///         })
    ///             .sheet(isPresented: $presentWarning, onDismiss: {
    ///                 syncPresent()
    ///             }, content: {
    ///                 WarningView(stateToBeSet: shownState.wrappedValue, realState: $developerModeOn, isPresented:  $presentWarning)
    ///             })
    ///         } setFunction: { _ in
    ///             presentWarning = true
    ///         } unsetFunction: { _ in
    ///             presentWarning = true
    ///         }
    ///
    /// - Parameter actualState: The actual state of the program. For example, if the data in the database is `false`, and is yet to be updated to `true`, then the variable that holds the value `false` is the actual state.
    /// - Parameter stateContentView: A ViewBuilder function that builds the view you need to present the current state. For example, you put a toggle that can interact with the user and show the state that the user want it to be.
    /// E.g., the user wants to turn it on so they tap to turn the toggle in this closure on.
    /// Although there are still things to be done before the specific stuff(like a function or a property) is really turned on, the state of the toggle is immediately turned on once the user does so. In this case, the toggle represents the state that is about to be changed to.
    ///
    /// `StateView` provides three parameters in this closure to help you construct your `stateContentView`. You may capture them in the closure.
    ///
    /// `shownState` is the state shown on the screen, i.e. the state of the toggle in the example.
    ///
    /// `actualState` is the actual state, which is identical to what you passed into the first parameter.
    ///
    /// `syncPresent` is the function you can use to sync the actual state to the shown state. For example, when the user turns the toggle on and you ask the user to confirm. If the user choose not to confirm, then the toggle state should be changed back to `false`, which is the same to the actual state. In this situation, you use this function to sync the state.
    ///
//    / - Warning: Never write your own code like
//    / ```shownState.wrappedValue = actualState.wrappedValue```.
//    / This can cause unexpected behavior. You should always use the function`syncPresent` provided in the closure.
    ///
    /// - Parameter setFunction: Things to do when the user attempts to turn the toggle on, with a `syncPresent` function mentioned in the discussion.
    /// - Parameter unsetFunction: Things to do when the user attempts to turn the toggle off, with a `syncPresent` function mentioned in the discussion.
    public init(actualState: Binding<Bool>,
         @ViewBuilder stateContentView: @escaping (_ shownState: Binding<Bool>, _ actualState: Binding<Bool>, _ syncPresent: @escaping () -> Void) -> Content,
         setFunction: @escaping (_ syncPresent: @escaping () -> Void) -> Void = {_ in },
         unsetFunction: @escaping (_ syncPresent: @escaping () -> Void) -> Void = {_ in }
    ) {
        self.set = actualState.wrappedValue
        self._setted = actualState
        self.stateContentView = stateContentView
        self.setFunction = setFunction
        self.unsetFunction = unsetFunction
    }
    
    public var body: some View {
        ZStack {
            stateContentView(self.$set, self.$setted, syncPresent)
            .valueChanged(value: set) { goSet in
                if goSet == setted {
                } else {
                    if goSet {
                        self.setFunction(syncPresent)
                    } else {
                        self.unsetFunction(syncPresent)
                    }
                }
            }
            .valueChanged(value: setted) { settedState in
//                self.noAction = true
                self.set = settedState
//                Timer.scheduledTimer(withTimeInterval: 0.001, repeats: false) { _ in
//                    noAction = false
//                }
            }
        }
    }
    
    public func syncPresent() {
//        noAction = true
        self.set = self.setted
//        Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: false) { _ in
//            noAction = false
//        }
    }
}



/// Implementation: https://betterprogramming.pub/implementing-swiftui-onchange-support-for-ios13-577f9c086c9
extension View {
    /// A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
