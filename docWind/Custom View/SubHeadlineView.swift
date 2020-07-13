//
//  SubHeadlineView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SubHeadlineView: View {
    
    @State var title = ""
    
    var body: some View {
        HStack {
            Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
                .padding([.top, .leading, .trailing])
            Spacer()
        }
    }
}

struct SubHeadlineView_Previews: PreviewProvider {
    static var previews: some View {
        SubHeadlineView()
    }
}
