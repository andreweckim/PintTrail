import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onBarcodeScanned = { barcode in
            onBarcodeScanned(barcode)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        nonisolated(unsafe) var onBarcodeScanned: ((String) -> Void)?
        nonisolated(unsafe) var hasScanned = false

        override func viewDidLoad() {
            super.viewDidLoad()
            setupCamera()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.bounds
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let session = captureSession, !session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if let session = captureSession, session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async {
                    session.stopRunning()
                }
            }
        }

        private func setupCamera() {
            let session = AVCaptureSession()
            captureSession = session

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                showNoCameraUI()
                return
            }

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.ean8, .ean13, .upce, .code128]
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
            view.layer.addSublayer(preview)
            previewLayer = preview

            // Scan overlay
            let overlayView = ScanOverlayView(frame: view.bounds)
            overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(overlayView)

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        private func showNoCameraUI() {
            let label = UILabel()
            label.text = "Camera not available"
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.frame = view.bounds
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(label)
        }

    }
}

extension BarcodeScannerView.ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else { return }

        hasScanned = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onBarcodeScanned?(barcode)
    }
}

class ScanOverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Dim background
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)

        // Clear center rectangle
        let scanWidth = min(rect.width * 0.7, 280.0)
        let scanHeight = scanWidth * 0.6
        let scanRect = CGRect(
            x: (rect.width - scanWidth) / 2,
            y: (rect.height - scanHeight) / 2 - 40,
            width: scanWidth,
            height: scanHeight
        )
        context.clear(scanRect)

        // Draw corner brackets
        let cornerLength: CGFloat = 20
        let lineWidth: CGFloat = 3
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineWidth(lineWidth)

        // Top-left
        context.move(to: CGPoint(x: scanRect.minX, y: scanRect.minY + cornerLength))
        context.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.minY))
        context.addLine(to: CGPoint(x: scanRect.minX + cornerLength, y: scanRect.minY))

        // Top-right
        context.move(to: CGPoint(x: scanRect.maxX - cornerLength, y: scanRect.minY))
        context.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY))
        context.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY + cornerLength))

        // Bottom-left
        context.move(to: CGPoint(x: scanRect.minX, y: scanRect.maxY - cornerLength))
        context.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.maxY))
        context.addLine(to: CGPoint(x: scanRect.minX + cornerLength, y: scanRect.maxY))

        // Bottom-right
        context.move(to: CGPoint(x: scanRect.maxX - cornerLength, y: scanRect.maxY))
        context.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY))
        context.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY - cornerLength))

        context.strokePath()
    }
}
