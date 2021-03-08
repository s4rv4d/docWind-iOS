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
import CoreGraphics

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
        AnyView(Text("Welcome to \n")
            .font(.title)
//            .fontWeight(.bold)
         + Text("doc")
            .font(.largeTitle)
            .fontWeight(.bold)
         + Text("Wind")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.blue))
    }
}

struct InfoView: View {
    
    @State var imageName: String
    @State var title: LocalizedStringKey
    @State var subTitle: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                Image(systemName: imageName)
                .font(.title)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing])
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.medium)
                    Text(subTitle)
//                        .padding(.leading)
//                        .font(.body)
                        .foregroundColor(.secondary)
                    .lineLimit(3)
//                        .multilineTextAlignment(.center)
                }
            }
            
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
    static var appURL = URL(string: "https://apps.apple.com/app/id1523280883")!
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
    
    static func openUrl(url: String) {
        let webUrl = URL(string: url)!
        UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
        
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
    private let text: LocalizedStringKey
    private let background: Color
    private let action: () -> Void
    
    //MARK: - Dependency injection
    init(text:LocalizedStringKey, background:Color = .red, action:@escaping() -> Void) {
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

struct ShinyButton: View {
    //describing buttons
    //MARK: - Properties
    private let text: LocalizedStringKey
    private let background: Color
    private let action: () -> Void
    
    //MARK: - Dependency injection
    init(text:LocalizedStringKey, background:Color = .red, action:@escaping() -> Void) {
        self.text = text
        self.background = background
        self.action = action
    }
    
    var body: some View {
        Button(action:action){
            HStack {
                Spacer()
                Text(text)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                }.padding()
                .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(background)
                )
            .cornerRadius(10)
        }
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

// MARK: - For carousel
struct Canvas<Content: View>: View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content:() -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
//            .background(Color.blue.edgesIgnoringSafeArea(.all))
    }
}

struct Item<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var _id: Int
    var content: Content
    
    @inlinable init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCard: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content:() -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCard * 2) - (spacing * 2)
        self.cardHeight = cardHeight
        self._id = _id
    }
    
    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}

struct Carousel<Items: View>: View {
    let items: Items
    let numberOfItems: CGFloat
    let spacing: CGFloat
    let widthOfHiddenCards: CGFloat
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items
    ) {
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards * 2) - (spacing * 2)
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
        var calcOffset = Float(activeOffset)
        
        if(calcOffset != Float(activeOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { (currentState, gestureState, transaction) in
            self.UIState.screenDrag = Float(currentState.translation.width)
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if(value.translation.width < -50 && CGFloat(self.UIState.activeCard) < self.numberOfItems - 1) {
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if(value.translation.width > 50 && CGFloat(self.UIState.activeCard) > 0) {
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}

// MARK: - Helper stuff for drawing
struct Drawing {
    var points: [CGPoint] = [CGPoint]()
}

struct Handle : View {
    private let handleThickness = CGFloat(5.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
}


struct ColorRow: View {
    
    
    var colorHex = ["#FF0000", "#FF00C3", "#6F00FF", "#0900FF", "#00FFEE", "#00FF33", "#1AFF00", "#EFFF00", "#FFDD00", "#FFA000", "#6C3A00", "#FFEF26", "#2C0C85", "#D333D3", "#FFFFFF", "#000000"]
    
    @Binding var selectedColor: Color
    
    var body: some View {
        var cards: [[Int]] = []
        _ = (0..<16).publisher
        .collect(8)
        .collect()
        .sink(receiveValue: { cards = $0 })
        
        return  ForEach(0..<cards.count, id:\.self) { array in
            HStack(alignment: .center) {
                ForEach(cards[array], id:\.self) { number in
                    Color(hex: self.colorHex[number])
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .clipShape(Circle()).overlay(Circle().stroke(Color.primary, lineWidth: (self.selectedColor == Color(hex: self.colorHex[number])) ? 4 : 0))
                        .onTapGesture {
                            self.selectedColor = Color(hex: self.colorHex[number])
                    }
                }
            }
        }
    }
}

struct HiddenModifier: ViewModifier {

    private let isHidden: Bool
    private let remove: Bool

    init(isHidden: Bool, remove: Bool = false) {
        self.isHidden = isHidden
        self.remove = remove
    }

    func body(content: Content) -> some View {
        Group {
            if isHidden {
                if remove {
                    EmptyView()
                } else {
                    content.hidden()
                }
            } else {
                content
            }
        }
    }
}
