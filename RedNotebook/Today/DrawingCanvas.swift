import PencilKit
import SwiftUI

/// A transparent PencilKit layer over the day page. Draw with a finger or Apple Pencil while `isActive`;
/// otherwise it just shows the drawing.
struct DrawingCanvas: UIViewRepresentable {
    @Binding var data: Data?
    let isActive: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput // iPhones have no Pencil, so fingers draw too
        canvas.isScrollEnabled = false   // the page scrolls, not the canvas
        canvas.tool = PKInkingTool(.pen, color: UIColor(Theme.ink), width: 3)
        if let data, let drawing = try? PKDrawing(data: data) {
            canvas.drawing = drawing
        }
        canvas.delegate = context.coordinator
        context.coordinator.toolPicker.addObserver(canvas)
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        context.coordinator.parent = self
        canvas.isUserInteractionEnabled = isActive

        let picker = context.coordinator.toolPicker
        picker.setVisible(isActive, forFirstResponder: canvas)
        if isActive {
            // The tool palette only appears once the canvas is first responder
            DispatchQueue.main.async { canvas.becomeFirstResponder() }
        } else if canvas.isFirstResponder {
            canvas.resignFirstResponder()
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvas
        let toolPicker = PKToolPicker()

        init(parent: DrawingCanvas) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let drawing = canvasView.drawing
            parent.data = drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
        }
    }
}
