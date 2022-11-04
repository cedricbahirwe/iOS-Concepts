//
//  HomeView.swift
//  P01-Shazam
//
//  Created by Cédric Bahirwe on 03/11/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var shazamSession = ShazamRecognizer()
    var body: some View {
        ZStack {
            NavigationView {
                VStack {

                    Button {
                        shazamSession.listenToMusic()

                    } label: {
                        Image(systemName: shazamSession.isRecording ? "stop" : "mic")
                            .symbolVariant(.fill)
                            .font(.system(size: 40).bold())
                            .padding(30)
                            .background(Color.cyan,
                                        in: Circle())
                            .foregroundStyle(.white)

                    }

                }
                .navigationTitle("Shazaming")

            }

            if let track = shazamSession.matchedTrack {
                AsyncImage(url: track.artworkURL ?? URL(string: "")!) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.white
                    }
                }
                .overlay(.ultraThinMaterial)
                .frame(width: UIScreen.main.bounds.width)

                VStack(spacing: 15) {
                    AsyncImage(url: track.artworkURL ?? URL(string: "")!) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 100, height: 300)
                                .cornerRadius(12)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 100, height: 300)

                    Group {
                        Text(track.title ?? "")
                            .font(.title.bold())
                            .foregroundStyle(.pink.opacity(0.8))

                        Text("Artist: **\(track.artist ?? "")**")
                            .font(.title2.weight(.semibold))
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Genres")
                            .padding(.leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(track.genres, id: \.self) { genre  in
                                    Button {
                                        //
                                    } label: {
                                        Text(genre)
                                            .font(.caption)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .buttonBorderShape(.capsule)
                                    .controlSize(.regular)
                                    .tint(.black)
                                }

                            }
                            .padding(.horizontal)
                        }
                    }

                    if let appleLink = track.appleMusicURL {
                        Link(destination: appleLink) {
                            Text("Continue in Apple Music")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.pink)
                        .padding(.horizontal)

                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topTrailing) {
                    Button(action: shazamSession.reset) {
                        Image(systemName: "xmark")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .padding(10)
                            .background(Color.pink, in: Circle())
                            .foregroundStyle(.white)
                    }
                    .padding(16)
                }
            }
        }
        .alert(item: $shazamSession.error) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .default(
                    Text("Okay!"),
                    action: {

                    })
            )
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
