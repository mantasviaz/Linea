//
//  HomeScreenView.swift
//  Linea
//
//
//

import SwiftUI
import AVKit


struct HomeScreenView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    LoopingVideoPlayer(videoName: "video", videoType: "mov")
                        .frame(
                            width: geometry.size.width * 1.15,
                            height: geometry.size.height * 0.75
                        )
                        .position(x: geometry.size.width / 1.95, y: geometry.size.height / 3.7)
                    
                    Text("Linea")
                    .font(Font.custom("PlaywriteUSModern-Regular", size: 48))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                    
                    loginCard(logo: "apple.logo", brand: "Apple")
                        .padding(.bottom, 7)
                    
                    loginCard(logo: "googleLogo", brand: "Google")
                        .padding(.bottom, 7)
                    
                    loginCard(logo: "", brand: "")
                        .padding(.bottom, geometry.size.height / 12)
                    
                }
                
            }
        }
    }
}

struct LoopingVideoPlayer: UIViewRepresentable {
    var videoName: String
    var videoType: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName, videoType: videoType)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?

    init(videoName: String, videoType: String) {
        super.init(frame: .zero)

        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else { return }
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer()
        self.queuePlayer = queuePlayer

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        self.playerLayer = playerLayer
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)

        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)

        queuePlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(resizeLayer), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func resizeLayer() {
        playerLayer?.frame = self.bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
}


#Preview {
    HomeScreenView()
}

extension HomeScreenView {
    private func loginCard(logo: String, brand: String) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if brand == "Apple" {
                Image(systemName: logo)
            } else if brand == "Google" {
                Image(logo)
                    .resizable()
                    .frame(width: 16, height: 16, alignment: .center)
            }
            
            Text(!brand.isEmpty ? "Sign in with \(brand)" : "Continue without Sign In")
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .foregroundColor(!brand.isEmpty ? .black : .white)
                .padding(.leading, 5)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 0)
        .frame(width: 308, height: 54, alignment: .center)
        .background(!brand.isEmpty ? .white : .black)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
            .inset(by: 0.5)
            .stroke(brand.isEmpty ? Color(red: 0.3, green: 0.3, blue: 0.3) : .black, lineWidth: 2)
        )
        .cornerRadius(14)
    }
}
