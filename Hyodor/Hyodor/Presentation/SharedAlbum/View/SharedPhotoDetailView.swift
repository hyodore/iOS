//
//  SharedPhotoDetailView.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//
import SwiftUI
import Kingfisher

struct SharedPhotoDetailView: View {
    let photo: SharedPhoto 
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            KFImage(photo.imageURL)
                .placeholder {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
