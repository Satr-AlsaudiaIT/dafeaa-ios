//
//  GoogleMapView.swift
//  Dafeaa
//
//  Created by AMNY on 06/01/2026.
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var cameraPosition: GMSCameraPosition
    let onTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = cameraPosition
        options.frame = .zero

        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.animate(to: cameraPosition)

        if let c = selectedCoordinate {
            if context.coordinator.marker == nil {
                let m = GMSMarker(position: c)
                m.icon = GMSMarker.markerImage(with: .yellow)
                m.map = mapView
                context.coordinator.marker = m
            } else {
                context.coordinator.marker?.position = c
                context.coordinator.marker?.map = mapView
            }
        } else {
            context.coordinator.marker?.map = nil
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, GMSMapViewDelegate {
        let parent: GoogleMapView
        var marker: GMSMarker?

        init(_ parent: GoogleMapView) { self.parent = parent }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            parent.onTap(coordinate)
        }
    }
}
