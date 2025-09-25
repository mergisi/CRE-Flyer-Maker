//
//  ToastView.swift
//  CRE Flyer Maker
//
//  Created by mustafa ergisi on 9/22/25.
//

import SwiftUI

struct Toast: Equatable {
    var message: String
    var type: ToastType
    var duration: Double = 3.0
    
    enum ToastType {
        case success
        case error
        case info
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return AppColors.primaryBlue
            }
        }
    }
}

struct ToastView: View {
    let toast: Toast
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.iconName)
                .font(.system(size: 24))
                .foregroundColor(toast.type.color)
            
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var isShowing = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if let toast = toast, isShowing {
                    ToastView(toast: toast, isShowing: $isShowing)
                        .onDisappear {
                            self.toast = nil
                        }
                }
                Spacer()
            }
            .padding(.top, 50)
            .animation(.spring(), value: isShowing)
        }
        .onChange(of: toast) { newValue in
            isShowing = newValue != nil
        }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
