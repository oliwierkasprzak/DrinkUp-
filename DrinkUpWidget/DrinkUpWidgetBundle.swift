//
//  DrinkUpWidgetBundle.swift
//  DrinkUpWidget
//
//  Created by Oliwier Kasprzak on 23/05/2023.
//

import WidgetKit
import SwiftUI

@main
struct DrinkUpWidgetBundle: WidgetBundle {
    var body: some Widget {
        DrinkUpWidget()
        DrinkUpWidgetLiveActivity()
    }
}
