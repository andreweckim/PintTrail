import Foundation

struct BarcodeProduct {
    let name: String
    let brand: String
    let style: String
    let imageURL: URL?
}

actor BarcodeService {
    func lookup(barcode: String) async throws -> BarcodeProduct? {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name,brands,categories_tags,image_url"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue("PintTrail iOS App - https://github.com/andreweckim/PintTrail", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let status = json?["status"] as? Int, status == 1,
              let product = json?["product"] as? [String: Any] else {
            return nil
        }

        let name = product["product_name"] as? String ?? ""
        let brand = product["brands"] as? String ?? ""
        let categories = product["categories_tags"] as? [String] ?? []
        let imageURLString = product["image_url"] as? String

        // Extract beer style from categories
        let style = extractBeerStyle(from: categories)

        let imageURL: URL? = if let imageURLString {
            URL(string: imageURLString)
        } else {
            nil
        }

        guard !name.isEmpty else { return nil }

        return BarcodeProduct(name: name, brand: brand, style: style, imageURL: imageURL)
    }

    private func extractBeerStyle(from categories: [String]) -> String {
        let styleMap: [(tag: String, label: String)] = [
            ("en:ipa", "IPA"),
            ("en:india-pale-ale", "IPA"),
            ("en:stouts", "Stout"),
            ("en:stout", "Stout"),
            ("en:porters", "Porter"),
            ("en:porter", "Porter"),
            ("en:lagers", "Lager"),
            ("en:lager", "Lager"),
            ("en:pilsners", "Pilsner"),
            ("en:pilsner", "Pilsner"),
            ("en:wheat-beers", "Wheat Beer"),
            ("en:pale-ales", "Pale Ale"),
            ("en:pale-ale", "Pale Ale"),
            ("en:amber-ales", "Amber Ale"),
            ("en:brown-ales", "Brown Ale"),
            ("en:sour-beers", "Sour"),
            ("en:belgian-ales", "Belgian Ale"),
            ("en:hefeweizen", "Hefeweizen"),
            ("en:saisons", "Saison"),
            ("en:blonde-ales", "Blonde Ale"),
        ]

        for category in categories {
            let lower = category.lowercased()
            for (tag, label) in styleMap {
                if lower == tag || lower.contains(tag) {
                    return label
                }
            }
        }

        return ""
    }
}
