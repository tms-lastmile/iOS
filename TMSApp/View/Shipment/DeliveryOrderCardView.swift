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
                            .frame(width: 40, height: 40)
                            .background(Color.orange)
                            .clipShape(Circle())
                            .accessibilityLabel("Simpan box")
                    }

                    Button(action: onAddBoxTapped) {
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(width: 40, height: 40)
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
    var onCalculateTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nama Box")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Label(box.isSaved ? "Tersimpan di server" : "Belum disimpan di server", systemImage: box.isSaved ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(box.isSaved ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .foregroundColor(box.isSaved ? .green : .red)
                    .cornerRadius(8)
            }
            
            Text(box.name)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.middle)
            
            HStack {
                if !box.isSaved {
                    if (box.pcUrl ?? "").isEmpty {
                        Label("Belum discan", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Label("Siap disimpan", systemImage: "tray.and.arrow.down.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                } else {
                    if (box.pcUrl ?? "").isEmpty {
                        Label("Perlu scan untuk hitung", systemImage: "camera.badge.exclamationmark")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Label("Siap dihitung", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Text("Ukuran: \(box.length) × \(box.width) × \(box.height)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Quantity: \(box.quantity)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                BoxActionButton(icon: "camera.viewfinder", color: .blue, label: "Scan", action: onScanTapped)
                BoxActionButton(icon: "trash", color: .red, label: "Hapus", action: onDeleteTapped)
                BoxActionButton(icon: "ruler", color: (box.isSaved && !(box.pcUrl ?? "").isEmpty) ? .purple : .gray, label: "Hitung", action: onCalculateTapped, disabled: !(box.isSaved && !(box.pcUrl ?? "").isEmpty))
            }
            
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 3)
    }
}

struct BoxActionButton: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(disabled ? Color.gray.opacity(0.5) : color)
                    .clipShape(Circle())
            }
            .disabled(disabled)

            Text(label)
                .font(.caption2)
                .foregroundColor(.primary)
        }
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
