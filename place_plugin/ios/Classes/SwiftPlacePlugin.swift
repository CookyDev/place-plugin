import Flutter
import UIKit
import GooglePlaces

public class SwiftPlacePlugin: NSObject, FlutterPlugin {
    
    var client: GMSPlacesClient!
    var token: GMSAutocompleteSessionToken?
    var filter: GMSAutocompleteFilter!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "place_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftPlacePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  
    if(call.method == "search"){
        if let args = call.arguments as? Dictionary<String, Any>, let keyword = args["keyword"] as? String{
            client.findAutocompletePredictions(fromQuery: keyword, filter: filter, sessionToken: token) { predictions, error in
                if error != nil {
                    result(nil)
                    return
                }
                if let results = predictions, results.count > 0 {
                    var array: Array<Any> = []
                    for prediction in results {
                        if !prediction.attributedPrimaryText.string.isEmpty{
                            let dic = ["name":prediction.attributedPrimaryText.string,
                                        "address": prediction.attributedSecondaryText?.string ?? "",
                                        "formattedAddress": prediction.attributedFullText.string,
                                        "placeId":prediction.placeID]
                            array.append(dic)
                        }
                    }
                    result(array)
                }else{
                    result([])
                }
            }
        }else{
            result(nil)
        }
        

    }else if(call.method == "initialize"){
        if let args = call.arguments as? Dictionary<String, Any>, let apiKey = args["apiKey"] as? String{
            GMSPlacesClient.provideAPIKey(apiKey)
            token = GMSAutocompleteSessionToken.init()
            filter = GMSAutocompleteFilter.init()
            filter.type = .noFilter
            filter.country = "vn"
            filter.accessibilityLanguage = "vi"
            client = GMSPlacesClient.init()
        }
    }else if(call.method == "getPlace"){
        if let args = call.arguments as? Dictionary<String, Any>, let placeId = args["placeId"] as? String{
            client.fetchPlace(fromPlaceID: placeId, placeFields: [GMSPlaceField.name, GMSPlaceField.addressComponents, GMSPlaceField.coordinate, GMSPlaceField.formattedAddress], sessionToken: token) { response, error in
                if error != nil {
                    result(nil)
                    return
                }
                if let place = response {
                    var city = ""
                    var district = ""
                    
                    if let components = place.addressComponents, components.count > 0 {
                        for component in components {
                            let types = component.types
                            if types.count > 0 {
                                for type in types {
                                    if type == "administrative_area_level_1" {
                                        city = component.name
                                        continue
                                    }else if type == "administrative_area_level_2" {
                                        district = component.name
                                        continue
                                    }
                                }
                            }
                        }
                    }
                    let placeDic: Dictionary = ["name":place.name,
                                                "formattedAddress":place.formattedAddress,
                                                "latitude": NSNumber.init(value: place.coordinate.latitude).stringValue,
                                                "longitude": NSNumber.init(value: place.coordinate.longitude).stringValue,
                                                "city": city,
                                                "district": district]
                    
                    result(placeDic)
                }else {
                    result(nil)
                }
            }
        }else{
            result(nil)
        }
    }else {
        result(FlutterMethodNotImplemented)
    }
  }

}
