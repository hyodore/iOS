//
//  SharedPhotoDetailView.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//
import SwiftUI

struct SharedPhotoDetailView: View {
    @State private var viewModel : SharedPhotoDetailVM

    init(photo: SharedPhoto){
        _viewModel = State(wrappedValue: SharedPhotoDetailVM(photo: photo))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task{
                await viewModel.loadImage()
            }
            }
    }
}
