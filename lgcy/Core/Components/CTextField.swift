import SwiftUI
import UIKit

struct CTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var axis: Axis.Set = .horizontal
    var isFocused: FocusState<Bool>.Binding?

    init(text: Binding<String>, placeholder: String, axis: Axis.Set = .horizontal, isFocused: FocusState<Bool>.Binding? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.axis = axis
        self.isFocused = isFocused
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CTextField

        init(parent: CTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused?.wrappedValue = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused?.wrappedValue = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.inputAccessoryView = UIView()  // Hide the accessory view
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

extension CTextField {
    func view(for axis: Axis.Set) -> some View {
        Group {
            if axis == .horizontal {
                HStack {
                    self
                }
            } else {
                VStack {
                    self
                }
            }
        }
    }
}
