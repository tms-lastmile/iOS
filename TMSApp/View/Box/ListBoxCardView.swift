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
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(box.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                if box.status == "processing" {
                    Text("Sedang menghitung dimensi")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 0.5)
                        )
                }
                else if box.status != "created" && box.status != "done" {
                    Text(box.status.capitalized)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                HStack(spacing: 12) {
                    dimensionText("P", value: box.length)
                    dimensionText("L", value: box.width)
                    dimensionText("T", value: box.height)
                }
                .padding(.top, 4)
            }

            Spacer()

            if box.status != "processing" {
                VStack(spacing: 4) {
                    Button(action: onCalculateTapped) {
                        Image(systemName: "ruler")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.primary))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("Hitung")
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }

    private func dimensionText(_ label: String, value: Double) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            Text("\(value, specifier: "%.1f") cm")
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
    }
}
