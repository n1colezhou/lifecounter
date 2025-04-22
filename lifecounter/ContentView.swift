import SwiftUI

struct ContentView: View {
    @State private var player1Life = 20
    @State private var player2Life = 20
    @State private var loserMessage: String? = nil
    
    let backgroundColor = Color(.systemBackground)
    let accentColor = Color(.systemBlue)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Life Counter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if geometry.size.width > geometry.size.height {
                        HStack(spacing: geometry.size.width * 0.05) {
                            playerView(
                                playerName: "Player 1",
                                life: $player1Life,
                                geometry: geometry,
                                isLandscape: true
                            )
                            
                            playerView(
                                playerName: "Player 2",
                                life: $player2Life,
                                geometry: geometry,
                                isLandscape: true
                            )
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    } else {
                        VStack(spacing: geometry.size.height * 0.04) {
                            playerView(
                                playerName: "Player 1",
                                life: $player1Life,
                                geometry: geometry,
                                isLandscape: false
                            )
                            
                            playerView(
                                playerName: "Player 2",
                                life: $player2Life,
                                geometry: geometry,
                                isLandscape: false
                            )
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                    
                    if let message = loserMessage {
                        Text(message)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: geometry.size.width * 0.9)
                            .multilineTextAlignment(.center)
                    } else {
                        Spacer()
                            .frame(height: 50)
                    }
                }
                .padding(.bottom)
                .onChange(of: player1Life) {
                    checkForLoser()
                }
                .onChange(of: player2Life) {
                    checkForLoser()
                }
            }
        }
    }
    
    private func playerView(playerName: String, life: Binding<Int>, geometry: GeometryProxy, isLandscape: Bool) -> some View {
        let buttonSize = isLandscape ?
            min(geometry.size.width * 0.06, 50) :
            min(geometry.size.width * 0.12, 50)
        
        let fontSize = isLandscape ?
            min(geometry.size.width * 0.06, 48) :
            min(geometry.size.width * 0.15, 60)
        
        return VStack(spacing: 12) {
            Text(playerName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(accentColor)
            
            Text("\(life.wrappedValue)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding()
                .frame(minWidth: fontSize * 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
            
            HStack(spacing: isLandscape ? 10 : 15) {
                buttonView(title: "+", action: { life.wrappedValue += 1 }, size: buttonSize)
                buttonView(title: "-", action: { life.wrappedValue -= 1 }, size: buttonSize)
            }
            
            HStack(spacing: isLandscape ? 10 : 15) {
                buttonView(title: "+5", action: { life.wrappedValue += 5 }, size: buttonSize)
                buttonView(title: "-5", action: { life.wrappedValue -= 5 }, size: buttonSize)
            }
        }
        .padding(isLandscape ? 15 : 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
    
    private func buttonView(title: String, action: @escaping () -> Void, size: CGFloat) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: size * 1.5, height: size)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor)
                )
        }
    }
    
    private func checkForLoser() {
        if player1Life <= 0 {
            loserMessage = "Player 1 LOSES!"
        } else if player2Life <= 0 {
            loserMessage = "Player 2 LOSES!"
        } else {
            loserMessage = nil
        }
    }
}

#Preview {
    ContentView()
}
