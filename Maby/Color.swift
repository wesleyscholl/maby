import Foundation
import SwiftUI
import MabyKit

enum GenderColorScheme {
  case pink(light: Color, medium: Color, dark: Color)
  case blue(light: Color, medium: Color, dark: Color)
  case orange(light: Color, medium: Color, dark: Color)
  
  var light: Color {
    switch self {
    case .pink(let light, _, _):
      return light
    case .blue(let light, _, _):
      return light
    case .orange(let light, _, _):
      return light
    }
  }
  
  var medium: Color {
    switch self {
    case .pink(_, let medium, _):
      return medium
    case .blue(_, let medium, _):
      return medium
    case .orange(_, let medium, _):
      return medium
    }
  }
  
  var dark: Color {
    switch self {
    case .pink(_, _, let dark):
      return dark
    case .blue(_, _, let dark):
      return dark
    case .orange(_, _, let dark):
      return dark
    }
  }
  
  static func getColorScheme(for gender: Baby.Gender) -> GenderColorScheme {
    switch gender {
    case .girl:
      return .pink(light: colorLightPink, medium: colorMediumPink, dark: colorDarkPink)
    case .boy:
      return .blue(light: colorLightBlue, medium: colorMediumBlue, dark: colorDarkBlue)
    case .other:
      return .orange(light: colorLightOrange, medium: colorMediumOrange, dark: colorDarkOrange)
    }
  }
}

let colorLightPink = Color(red: 254/255, green: 242/255, blue: 242/255)
let colorMediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)
let colorDarkPink = Color(red: 246/255, green: 138/255, blue: 162/255)

let colorLightBlue = Color(red: 204/255, green: 235/255, blue: 255/255)
let colorMediumBlue = Color(red: 51/255, green: 173/255, blue: 255/255)
let colorDarkBlue = Color(red: 0/255, green: 122/255, blue: 255/255)

let colorLightOrange = Color(red: 255/255, green: 201/255, blue: 128/255)
let colorMediumOrange = Color(red: 255/255, green: 174/255, blue: 64/255)
let colorDarkOrange = Color(red: 255/255, green: 147/255, blue: 0/255)
