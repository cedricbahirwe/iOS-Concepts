//
//  ShazamTrack.swift
//  P01-Shazam
//
//  Created by Cédric Bahirwe on 03/11/2022.
//

import ShazamKit

struct ShazamTrack: Identifiable {
    let id: String
    let title: String?
    let subtitle: String?
    let artist: String?
    let webURL: URL?
    let appleMusicID: String?
    let appleMusicURL: URL?
    let artworkURL: URL?
    let videoURL: URL?
    let genres: [String]
    let isrc: String?

    init(_ item: SHMatchedMediaItem) {
        self.id = item.shazamID ?? UUID().uuidString
        self.title = item.title
        self.subtitle = item.subtitle
        self.artist = item.artist
        self.webURL = item.webURL
        self.appleMusicID = item.appleMusicID
        self.appleMusicURL = item.appleMusicURL
        self.artworkURL = item.artworkURL
        self.videoURL = item.videoURL
        self.genres = item.genres
        self.isrc = item.isrc
    }
}
