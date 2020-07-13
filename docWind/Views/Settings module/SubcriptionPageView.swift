//
//  SubcriptionPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SubcriptionPageView: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Image("docwind logo-1")
                        .resizable()
                        .frame(width: 100, height: 100)
                        
                    Text("doc")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                    + Text("Wind")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                       .foregroundColor(.blue)
                    
                    Image(systemName: "plus")
                        .foregroundColor(.yellow)
                    Spacer()
                }
            }
            
            HStack{
                Text("The docWind" )
                    .font(.title)
                    .fontWeight(.thin)
                    + Text("+")
                        .font(.title)
                        .foregroundColor(.yellow)
                + Text(" features include the following")
                    .font(.title)
                    .fontWeight(.thin)
            }.padding()
                .multilineTextAlignment(.center)
//            Spacer()
            HStack {
                VStack(spacing: 15) {
                    VStack {
                        Text("OCR Text recognition 👁")
                        .font(.body)
                        .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Get important info right after scanning a document")
                            .font(.body)
                            .fontWeight(.thin)
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        Text("Fill and Sign ✍️")
                        .font(.body)
                        .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Be able to edit your documents with annotations and custom signature")
                            .font(.body)
                            .fontWeight(.thin)
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        Text("Remove watermark 👣")
                        .font(.body)
                        .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Dont like the default watermark?, remove it with docWind+")
                            .font(.body)
                            .fontWeight(.thin)
                            .multilineTextAlignment(.center)
                    }


                }.padding()
//                Spacer()
            }.padding()
            Spacer()
            
            VStack {
                Text("Support an iOS developer 😄")
                .font(.subheadline)
//                .fontWeight(.bold)
                    .multilineTextAlignment(.center)
//                        Text("Dont like the default watermark?, well now you can remove them.")
//                            .font(.body)
//                            .fontWeight(.thin)
//                            .multilineTextAlignment(.leading)
            }
            VStack{
                Text("and more in the future updates 🤓")
                .font(.subheadline)
//                .fontWeight(.bold)
                    .multilineTextAlignment(.center)
//                        Text("Dont like the default watermark?, well now you can remove them.")
//                            .font(.body)
//                            .fontWeight(.thin)
//                            .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }
}

struct SubcriptionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SubcriptionPageView()
    }
}
