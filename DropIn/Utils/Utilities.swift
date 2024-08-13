import CryptoKit
import Foundation
import SwiftUI
import CoreLocation

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

@available(iOS 13, *)
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()

    return hashString
}

func copyToClipboard(text: String) {
    UIPasteboard.general.string = text
}

func openInAppleMaps(coordinate: CLLocationCoordinate2D) {
    let urlString = "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=Pin"
    if let url = URL(string: urlString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

func openInGoogleMaps(coordinate: CLLocationCoordinate2D) {
    let urlString = "comgooglemaps://?q=\(coordinate.latitude),\(coordinate.longitude)&zoom=14"
    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        let browserURLString = "https://maps.google.com/?q=\(coordinate.latitude),\(coordinate.longitude)&zoom=14"
        if let browserURL = URL(string: browserURLString) {
            UIApplication.shared.open(browserURL, options: [:], completionHandler: nil)
        }
    }
}

func createKMLFile(from locations: Set<Location>) -> URL? {
    let kmlHeader = """
    <?xml version="1.0" encoding="UTF-8"?>
    <kml xmlns="http://www.opengis.net/kml/2.2">
    <Document>
    """
    
    let kmlFooter = """
    </Document>
    </kml>
    """
    
    var kmlBody = ""
    
    for location in locations {
        let placemark = """
        <Placemark>
            <name>\(location.name)</name>
            <description>\(location.description ?? "")</description>
            <Point>
                <coordinates>\(location.longitude),\(location.latitude),0</coordinates>
            </Point>
        </Placemark>
        """
        kmlBody += placemark
    }
    
    let kmlContent = kmlHeader + kmlBody + kmlFooter
    
    let fileName = "locations.kml"
    if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        do {
            try kmlContent.data(using: .utf8)?.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing KML file: \(error)")
        }
    }
    
    return nil
}

func shareKMLFile(from locations: Set<Location>, in viewController: UIViewController) {
    guard let kmlFileURL = createKMLFile(from: locations) else { return }

    let activityViewController = UIActivityViewController(activityItems: [kmlFileURL], applicationActivities: nil)
    
    activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .addToReadingList]
    
    viewController.present(activityViewController, animated: true, completion: nil)
}
