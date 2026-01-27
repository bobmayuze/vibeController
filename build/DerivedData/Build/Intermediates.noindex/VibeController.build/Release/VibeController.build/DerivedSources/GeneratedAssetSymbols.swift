import Foundation
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "BtnA" asset catalog image resource.
    static let btnA = DeveloperToolsSupport.ImageResource(name: "BtnA", bundle: resourceBundle)

    /// The "BtnB" asset catalog image resource.
    static let btnB = DeveloperToolsSupport.ImageResource(name: "BtnB", bundle: resourceBundle)

    /// The "BtnX" asset catalog image resource.
    static let btnX = DeveloperToolsSupport.ImageResource(name: "BtnX", bundle: resourceBundle)

    /// The "BtnY" asset catalog image resource.
    static let btnY = DeveloperToolsSupport.ImageResource(name: "BtnY", bundle: resourceBundle)

    /// The "ControllerImage" asset catalog image resource.
    static let controller = DeveloperToolsSupport.ImageResource(name: "ControllerImage", bundle: resourceBundle)

    /// The "DPad" asset catalog image resource.
    static let dPad = DeveloperToolsSupport.ImageResource(name: "DPad", bundle: resourceBundle)

    /// The "DPadDown" asset catalog image resource.
    static let dPadDown = DeveloperToolsSupport.ImageResource(name: "DPadDown", bundle: resourceBundle)

    /// The "DPadLeft" asset catalog image resource.
    static let dPadLeft = DeveloperToolsSupport.ImageResource(name: "DPadLeft", bundle: resourceBundle)

    /// The "DPadRight" asset catalog image resource.
    static let dPadRight = DeveloperToolsSupport.ImageResource(name: "DPadRight", bundle: resourceBundle)

    /// The "DPadUp" asset catalog image resource.
    static let dPadUp = DeveloperToolsSupport.ImageResource(name: "DPadUp", bundle: resourceBundle)

    /// The "HomeBtn" asset catalog image resource.
    static let homeBtn = DeveloperToolsSupport.ImageResource(name: "HomeBtn", bundle: resourceBundle)

    /// The "LB" asset catalog image resource.
    static let LB = DeveloperToolsSupport.ImageResource(name: "LB", bundle: resourceBundle)

    /// The "LT" asset catalog image resource.
    static let LT = DeveloperToolsSupport.ImageResource(name: "LT", bundle: resourceBundle)

    /// The "LeftStick" asset catalog image resource.
    static let leftStick = DeveloperToolsSupport.ImageResource(name: "LeftStick", bundle: resourceBundle)

    /// The "MenuBtn" asset catalog image resource.
    static let menuBtn = DeveloperToolsSupport.ImageResource(name: "MenuBtn", bundle: resourceBundle)

    /// The "RB" asset catalog image resource.
    static let RB = DeveloperToolsSupport.ImageResource(name: "RB", bundle: resourceBundle)

    /// The "RT" asset catalog image resource.
    static let RT = DeveloperToolsSupport.ImageResource(name: "RT", bundle: resourceBundle)

    /// The "RightStick" asset catalog image resource.
    static let rightStick = DeveloperToolsSupport.ImageResource(name: "RightStick", bundle: resourceBundle)

    /// The "ViewBtn" asset catalog image resource.
    static let viewBtn = DeveloperToolsSupport.ImageResource(name: "ViewBtn", bundle: resourceBundle)

    /// The "XboxLogo" asset catalog image resource.
    static let xboxLogo = DeveloperToolsSupport.ImageResource(name: "XboxLogo", bundle: resourceBundle)

}

