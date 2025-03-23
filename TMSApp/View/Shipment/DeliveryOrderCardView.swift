//
//  DeliveryOrderCardView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct DeliveryOrderCardView: View {
    let deliveryOrder: DeliveryOrder
    var isExpanded: Bool
    var onAddBoxTapped: () -> Void
    var onToggle: () -> Void
    var onSaveBoxesTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(deliveryOrder.deliveryOrderNum)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Tap untuk lihat / sembunyikan box")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: onSaveBoxesTapped) {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.orange)
                            .clipShape(Circle())
                            .accessibilityLabel("Simpan box")
                    }

                    Button(action: onAddBoxTapped) {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green)
                            .clipShape(Circle())
                            .accessibilityLabel("Tambah box")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct BoxCardView: View {
    let box: Box
    var onScanTapped: () -> Void
    var onDeleteTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Box ID")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                if box.isSaved {
                    Text("Tersimpan")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                } else {
                    Text("Belum disimpan")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(6)
                }
            }

            Text(box.id)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.middle)

            Text("Dimensi: \(box.length) x \(box.width) x \(box.height)")
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: onScanTapped) {
                    Image(systemName: "camera.viewfinder")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                Button(action: onDeleteTapped) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    DeliveryOrderCardView(
        deliveryOrder: DeliveryOrder(
            id: 1,
            deliveryOrderNum: "DO-987654",
            boxes: []
        ),
        isExpanded: false,
        onAddBoxTapped: {
            print("Box ditambahkan")
        },
        onToggle: {
            print("Toggle")
        },
        onSaveBoxesTapped: {
            print("Box disimpan")
        }
    )
}
