//
//  ContentView.swift
//  UIKitToSwiftScanner
//

import SwiftUI

struct ContentView: View {
    @State private var isCameraShowing = false

    var body: some View {
        VStack {
            Button("click") {
                isCameraShowing = true
            }
            .sheet(isPresented: $isCameraShowing) {
                BarcodeScannerView { barcode in
                    print("Detected barcode: \(barcode)")
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            Text("Click to scan barcode")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
