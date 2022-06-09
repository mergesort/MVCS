import SwiftUI

extension Color {
    static let palette = Color.Palette()
}

extension Color {

    struct Palette {
        var primary: Color {
            Color(red: colorValue(195), green: colorValue(82), blue: colorValue(43))
        }

        var secondary: Color {
            Color(red: colorValue(227), green: colorValue(114), blue: colorValue(75))
        }

        var tertiary: Color {
            Color(red: colorValue(255), green: colorValue(162), blue: colorValue(123))
        }

        var background: Color {
            Color(red: colorValue(236), green: colorValue(240), blue: colorValue(241))
        }
    }

}

// I'm too lazy to build a real palette for this project so bear with me.
private extension Color {

    static func colorValue(_ fromRGBValue: Int) -> Double {
        return Double(fromRGBValue)/255.0
    }

}

