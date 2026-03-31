import SwiftUI
import CoreImage.CIFilterBuiltins

struct InviteView: View {
    let crawl: PubCrawl
    @Environment(\.dismiss) private var dismiss

    private var deepLink: String {
        "pinttrail://crawl/join/\(crawl.inviteCode)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Invite Friends")
                    .font(.title.bold())

                Text("Share this code or QR to let friends join your crawl")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Invite code
                Text(crawl.inviteCode)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // QR Code
                if let qrImage = generateQRCode(from: deepLink) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Share button
                ShareLink(
                    item: "Join my pub crawl \"\(crawl.name)\" on Pint Trail! Code: \(crawl.inviteCode)",
                    subject: Text("Join my pub crawl!"),
                    message: Text("Join my pub crawl \"\(crawl.name)\" on Pint Trail! Code: \(crawl.inviteCode)")
                ) {
                    Label("Share Invite", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scale = 10.0
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
