//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for any form-based component.
public struct FormComponentStyle: ViewStyle {
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// The header style.
    public var header: FormHeaderStyle = FormHeaderStyle()
    
    /// The text field style.
    public var textField: FormTextItemStyle = FormTextItemStyle()
    
    /// The switch style.
    public var `switch`: FormSwitchItemStyle = FormSwitchItemStyle()
    
    /// The footer style.
    public var footer: FormFooterStyle
    
    /// The main button style.
    @available(*, deprecated, message: "Use mainButtonItem instead.")
    public var mainButton: ButtonStyle {
        get { mainButtonItem.button }
        
        set {
            mainButtonItem.button = newValue
        }
    }
    
    /// The secondary button style.
    @available(*, deprecated, message: "Use secondaryButtonItem instead.")
    public var secondaryButton: ButtonStyle {
        get { secondaryButtonItem.button }
        
        set {
            secondaryButtonItem.button = newValue
        }
    }
    
    /// The main button style.
    public var mainButtonItem: FormButtonItemStyle = .main(font: .preferredFont(forTextStyle: .headline),
                                                           textColor: .white,
                                                           mainColor: UIColor.AdyenCore.defaultBlue)
    
    /// The secondary button style.
    public var secondaryButtonItem: FormButtonItemStyle = .secondary(font: .preferredFont(forTextStyle: .body),
                                                                     textColor: UIColor.AdyenCore.defaultBlue)
    
    /// The color for separator element.
    /// When set, updates separator colors for all undelying styles unless the value were set previously.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor? {
        didSet {
            textField.separatorColor = textField.separatorColor ?? separatorColor
            `switch`.separatorColor = `switch`.separatorColor ?? separatorColor
        }
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The header style.
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter footer: The footer style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    public init(header: FormHeaderStyle,
                textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                footer: FormFooterStyle,
                mainButton: FormButtonItemStyle,
                secondaryButton: FormButtonItemStyle) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = footer
        self.mainButtonItem = mainButton
        self.secondaryButtonItem = secondaryButton
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The header style.
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    public init(header: FormHeaderStyle,
                textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                mainButton: ButtonStyle,
                secondaryButton: ButtonStyle) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = FormFooterStyle(button: mainButton)
        self.mainButtonItem = FormButtonItemStyle(button: mainButton)
        self.secondaryButtonItem = FormButtonItemStyle(button: secondaryButton)
    }
    
    /// Initializes the form style with the default style and custom tint for all elements.
    /// - Parameter tintColor: The color for tinting buttons. textfields, icons and switches.
    public init(tintColor: UIColor) {
        self.init()
        
        mainButtonItem.button.backgroundColor = tintColor
        secondaryButtonItem.button.title.color = tintColor
        
        footer = FormFooterStyle(button: mainButtonItem.button)
        textField = FormTextItemStyle(tintColor: tintColor)
        `switch`.tintColor = tintColor
    }
    
    /// Initializes the form style with the default style.
    public init() {
        self.footer = FormFooterStyle()
    }
    
}
