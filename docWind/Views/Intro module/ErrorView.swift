//
//  ErrorView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        VStack {
            Text("iCloud drive ❌")
                .font(.largeTitle)
            Text("The iCloud drive needs to be switched on, this app uses iCloud containers to store data.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(alignment: .leading) {
                Text("To switch on your iCloud drive follow these steps:")
                    .font(.title)
                    .padding(.bottom)
                VStack(alignment: .leading, spacing: 20) {
                    Text("1. Go to the settings app 🛠")
                    Text("2. Tap on your account name 👾")
                    Text("3. Tap on iCloud ☁️")
                    Text("4. Switch on iCloud drive ☁️")
                    Text("5. Restart app 📱")
                    Text("6. and you're good to go 🤙")
                }
            }
            .padding()
            Spacer()
            DWButton(text: "Open Settings", background: .red) {
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        }.padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
