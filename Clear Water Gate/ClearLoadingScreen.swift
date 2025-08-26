import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct ClearLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        ClearProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct ClearBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct ClearProgressBar: View {
    let value: Double
    @State private var waveOffset: CGFloat = 0
    @State private var energyParticles: [EnergyParticle] = []
    @State private var electricPulse: CGFloat = 0
    @State private var plasmaGlow: Double = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                backgroundTrack(in: geometry)
                liquidProgressTrack(in: geometry)
                energyParticleSystem(in: geometry)
                electricCurrentEffect(in: geometry)
                plasmaBorder(in: geometry)
            }
            .onAppear {
                startWaveAnimation()
                startElectricPulse()
                startPlasmaGlow()
                generateEnergyParticles(width: geometry.size.width)
            }
        }
    }

    private func backgroundTrack(in geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: geometry.size.height / 2)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0D0D0D"),
                        Color(hex: "#1A1A2E"),
                        Color(hex: "#000000"),
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: geometry.size.height
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#00FFFF").opacity(0.4),
                                Color(hex: "#FF00FF").opacity(0.3),
                                Color(hex: "#FFFF00").opacity(0.2),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
    }

    private func liquidProgressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основная жидкая заливка с волновым эффектом
            WavePath(offset: waveOffset, progress: value)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#00FFFF"),
                            Color(hex: "#0080FF"),
                            Color(hex: "#8000FF"),
                            Color(hex: "#FF0080"),
                            Color(hex: "#FF4000"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: height / 2))
                .shadow(color: Color(hex: "#00FFFF").opacity(0.8), radius: 15, x: 0, y: 0)
                .shadow(color: Color(hex: "#FF0080").opacity(0.6), radius: 25, x: 0, y: 0)

            // Дополнительный внутренний слой для глубины
            WavePath(offset: waveOffset * 0.7, progress: value)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.clear,
                            Color.white.opacity(0.4),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height * 0.4)
                .clipShape(RoundedRectangle(cornerRadius: height / 2))
                .offset(y: -height * 0.15)

            // Энергетический поток
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.9),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.2, height: height)
                .offset(x: (waveOffset * 0.5) * width - width * 0.1)
                .clipShape(RoundedRectangle(cornerRadius: height / 2))
                .blendMode(.overlay)
        }
        .animation(.easeInOut(duration: 0.4), value: value)
    }

    private func energyParticleSystem(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width

        return ZStack {
            ForEach(energyParticles.indices, id: \.self) { index in
                if energyParticles[index].x <= width {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    energyParticles[index].color.opacity(1.0),
                                    energyParticles[index].color.opacity(0.8),
                                    Color.clear,
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: energyParticles[index].size / 2
                            )
                        )
                        .frame(
                            width: energyParticles[index].size,
                            height: energyParticles[index].size
                        )
                        .position(
                            x: energyParticles[index].x,
                            y: energyParticles[index].y + sin(
                                waveOffset * 4 + energyParticles[index].phase) * 2
                        )
                        .opacity(energyParticles[index].opacity)
                        .scaleEffect(energyParticles[index].scale)
                        .shadow(color: energyParticles[index].color, radius: 3, x: 0, y: 0)
                }
            }
        }
    }

    private func electricCurrentEffect(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Электрические разряды
            ForEach(0..<3, id: \.self) { i in
                ElectricPath(
                    start: CGPoint(x: 0, y: height / 2),
                    end: CGPoint(x: width, y: height / 2),
                    amplitude: CGFloat(i + 1) * 1.5,
                    frequency: Double(i + 2),
                    offset: electricPulse
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color(hex: "#FFFFFF").opacity(0.8),
                            Color(hex: "#00FFFF").opacity(0.6),
                            Color.clear,
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 0.5
                )
                .opacity(0.7)
                .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }

    private func plasmaBorder(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return RoundedRectangle(cornerRadius: height / 2)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#00FFFF").opacity(plasmaGlow),
                        Color(hex: "#FF00FF").opacity(plasmaGlow * 0.8),
                        Color(hex: "#FFFF00").opacity(plasmaGlow * 0.6),
                        Color(hex: "#00FFFF").opacity(plasmaGlow),
                    ]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 2
            )
            .frame(width: width, height: height)
            .shadow(color: Color(hex: "#00FFFF").opacity(plasmaGlow), radius: 8, x: 0, y: 0)
    }

    private func startWaveAnimation() {
        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            waveOffset = 1.0
        }
    }

    private func startElectricPulse() {
        withAnimation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false)) {
            electricPulse = 1.0
        }
    }

    private func startPlasmaGlow() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            plasmaGlow = 1.0
        }
    }

    private func generateEnergyParticles(width: CGFloat) {
        energyParticles = (0..<20).map { i in
            EnergyParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 1...9),
                size: CGFloat.random(in: 2...6),
                color: [
                    Color(hex: "#00FFFF"),
                    Color(hex: "#FF00FF"),
                    Color(hex: "#FFFF00"),
                    Color(hex: "#00FF80"),
                ].randomElement()!,
                opacity: Double.random(in: 0.4...0.9),
                scale: Double.random(in: 0.8...1.2),
                phase: CGFloat.random(in: 0...2 * .pi)
            )
        }
    }
}

// MARK: - Вспомогательные структуры для анимации

private struct WavePath: Shape {
    let offset: CGFloat
    let progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width * CGFloat(progress)
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height / 2))

        let waveHeight: CGFloat = 3.0
        let waveLength: CGFloat = width / 4

        for x in stride(from: 0, to: width, by: 2) {
            let relativeX = x / waveLength
            let sine = sin((relativeX + offset * 2) * .pi * 2)
            let y = height / 2 + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }
}

private struct ElectricPath: Shape {
    let start: CGPoint
    let end: CGPoint
    let amplitude: CGFloat
    let frequency: Double
    let offset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)

        let steps = 50
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + sin((t * .pi * CGFloat(frequency)) + offset * .pi * 2) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

private struct EnergyParticle {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let opacity: Double
    let scale: Double
    let phase: CGFloat
}

// MARK: - Превью

#Preview("Vertical") {
    ClearLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    ClearLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
