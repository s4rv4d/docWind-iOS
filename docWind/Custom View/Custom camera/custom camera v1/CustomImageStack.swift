//
//  CustomImageStack.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/9/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CustomImageStack: View {
    
    @Binding var images: [UIImage]
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    ForEach(0..<images.count, id: \.self) { index in
                        let uiimage = self.images[index]
                        Image(uiImage: uiimage)
                            .resizable()
//                            .frame(width: 120, height: 80)
                            .cornerRadius(8)
                            .aspectRatio(contentMode: .fit)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                            .stacked(at: index, in: self.images.count)
                            .animation(.easeIn)
                    }
                }
            }
        }
    }
}


//struct CustomImageStack2: View {
//
//    @Binding var images: [ImageToCombine]
//
//    var body: some View {
//        ZStack {
//            VStack {
//                ZStack {
//                    ForEach(0..<images.count, id: \.self) { index in
//                        let uiimage = self.images[index].image
//                        Image(uiImage: uiimage)
//                            .resizable()
//                            .frame(width: 120, height: 80)
//                            .cornerRadius(8)
//                            .aspectRatio(contentMode: .fill)
//                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
//                            .stacked(at: index, in: self.images.count)
//                            .animation(.easeIn)
//                    }
//                }
//            }
//        }
//    }
//}

//
//struct CustomImageStack_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomImageStack(images: .constant([UIImage()]))
//    }
//}


// Steps:
/// 1. Zstack
/// 2.  creates images array var
/// 3. use for loop to iterate through images
/// 4. while iterating apply view extension
/// 5. add frame options and beautify UI
