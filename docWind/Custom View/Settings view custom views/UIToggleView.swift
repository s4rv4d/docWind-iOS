//
//  UIToggleView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

final class UIToggle: UIViewRepresentable {

    @Binding var isOn: Bool
    var changedAction: (Bool) -> Void

    init(isOn: Binding<Bool>, changedAction: @escaping (Bool) -> Void) {
        self._isOn = isOn
        self.changedAction = changedAction
    }

    func makeUIView(context: Context) -> UISwitch {
        let uiSwitch = UISwitch()
        return uiSwitch
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = isOn
        uiView.addTarget(self, action: #selector(switchHasChanged(_:)), for: .valueChanged)

    }

    @objc func switchHasChanged(_ sender: UISwitch) {
        self.isOn = sender.isOn
        changedAction(sender.isOn)
    }
}
