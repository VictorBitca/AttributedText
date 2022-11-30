#if os(iOS)
  import SwiftUI

  extension AttributedTextImpl: UIViewRepresentable {
    func makeUIView(context: Context) -> TextView {
      TextView()
    }

    func updateUIView(_ uiView: TextView, context: Context) {
      uiView.attributedText = attributedText
      uiView.maxLayoutWidth = maxLayoutWidth

      uiView.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
      uiView.textContainer.lineBreakMode = NSLineBreakMode(
        truncationMode: context.environment.truncationMode
      )
      uiView.openLink = onOpenLink ?? { context.environment.openURL($0) }
      textSizeViewModel.didUpdateTextView(uiView)
    }
  }

  extension AttributedTextImpl {
    final class TextView: UITextView, UITextViewDelegate {
      var maxLayoutWidth: CGFloat = 0 {
        didSet {
          guard maxLayoutWidth != oldValue else { return }
          invalidateIntrinsicContentSize()
        }
      }

      var openLink: ((URL) -> Void)?

      override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        self.backgroundColor = .clear
        self.textContainerInset = .zero
        self.isEditable = false
        self.isSelectable = true
        self.isScrollEnabled = false
        self.textContainer.lineFragmentPadding = 0
        self.isUserInteractionEnabled = true
        self.delegate = self
      }

      required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override var intrinsicContentSize: CGSize {
        guard maxLayoutWidth > 0 else {
          return super.intrinsicContentSize
        }

        return sizeThatFits(CGSize(width: maxLayoutWidth, height: .greatestFiniteMagnitude))
      }

      func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openLink?(URL)
        return false
      }
    }
  }
#endif
