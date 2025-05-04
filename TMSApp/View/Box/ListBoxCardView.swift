//
//  ListBoxCardView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 04/05/25.
//

import SwiftUI

struct ListBoxCardView: View {
    let box: BoxModel
    var onCalculateTapped: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(box.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 16) {
                    dimensionText(title: "P", value: box.length)
                    dimensionText(title: "L", value: box.width)
                    dimensionText(title: "T", value: box.height)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 4) {
                Image(systemName: "ruler")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.black))
                    .onTapGesture {
                        onCalculateTapped()
                    }

                Text("Hitung")
                    .font(.caption2)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func dimensionText(title: String, value: Double) -> some View {
        HStack(spacing: 4) {
            Text(title).bold()
            Text("\(value, specifier: "%.1f") cm")
        }
    }
}

