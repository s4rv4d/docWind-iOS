//
//  Helper+Struct.swift
//  docWind
//
//  Created by Sarvad shetty on 7/1/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Helper struct
///use throughout the whole app

struct ColorStruct : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

struct TitleView: View {
    var body: some View {
        AnyView(Text("Welcome To \n")
            .font(.largeTitle)
            .fontWeight(.bold)
         + Text("docWind")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.blue))
    }
}

struct InfoView: View {
    
    @State var imageName: String
    @State var title: String
    @State var subTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: imageName)
                .font(.title)
                    .foregroundColor(.blue)
                Spacer()
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.bold)
                    Text(subTitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }.padding([.leading])
            
        }
    }
}

struct HostingWindowKey: EnvironmentKey {

#if canImport(UIKit)
    typealias WrappedValue = UIWindow
#elseif canImport(AppKit)
    typealias WrappedValue = NSWindow
#else
    #error("Unsupported platform")
#endif

    typealias Value = () -> WrappedValue? // needed for weak link
    static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
    var hostingWindow: HostingWindowKey.Value {
        get {
            return self[HostingWindowKey.self]
        }
        set {
            self[HostingWindowKey.self] = newValue
        }
    }
}

struct Device {
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}

public struct CodableColor {
    let color: UIColor
}

extension CodableColor: Encodable {

    public func encode(to encoder: Encoder) throws {
        let nsCoder = NSKeyedArchiver(requiringSecureCoding: true)
        color.encode(with: nsCoder)
        var container = encoder.unkeyedContainer()
        try container.encode(nsCoder.encodedData)
    }
}



extension CodableColor: Decodable {

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let decodedData = try container.decode(Data.self)
        let nsCoder = try NSKeyedUnarchiver(forReadingFrom: decodedData)
        guard let color = UIColor(coder: nsCoder) else {
            struct UnexpectedlyFoundNilError: Error {}
            throw UnexpectedlyFoundNilError()
        }
        self.color = color
    }
}

public extension UIColor {
    func codable() -> CodableColor {
        return CodableColor(color: self)
    }
}

struct CustomTextView: View {
    let text: String
    let bold: Bool
    let color: Color
    var body: some View {
        Text("\(text)")
        .font(.body)
            .fontWeight( bold ? .bold : .none)
        .foregroundColor(color)
    }
}

struct SettingsHelper {
    static var appURL = URL(string: "https://apps.apple.com/app/id1512587029")!
    static var personalTwitterApp = "twitter://user?screen_name=serverConnectd"
    static var personalTwitterWeb = "https://twitter.com/serverConnectd"
    static let email = "sarvadshetty@gmail.com"
    
    static func openTwitter(twitterURLApp: String, twitterURLWeb: String) {
        let twUrl = URL(string: twitterURLApp)!
        let twUrlWeb = URL(string: twitterURLWeb)!
        if UIApplication.shared.canOpenURL(twUrl) {
            UIApplication.shared.open(twUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(twUrlWeb, options: [:], completionHandler: nil)
        }
    }

    static func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) { return gmailUrl }
        else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) { return outlookUrl }
        else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail){ return yahooMail }
        return nil
    }

    static func writeReview() {
        var components = URLComponents(url: SettingsHelper.appURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
        guard let writeReviewURL = components?.url else { return }
        UIApplication.shared.open(writeReviewURL)
    }

}

struct DWButton: View {
    //describing buttons
    //MARK: - Properties
    private let text: String
    private let background: Color
    private let action: () -> Void
    
    //MARK: - Dependency injection
    init(text:String, background:Color = .red, action:@escaping() -> Void) {
        self.text = text
        self.background = background
        self.action = action
    }
    
    var body: some View {
        Button(action:action){
            HStack {
                Spacer()
                Text(text)
//                    .font(.title)
                .bold()
                    .foregroundColor(.white)
                Spacer()
                }.padding()
                .background(background)
            .cornerRadius(10)
        }
    .shadow(radius: 4)
    }
}
