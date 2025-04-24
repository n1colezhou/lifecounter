import SwiftUI

struct ContentView: View {
    @State private var players = [
        Player(id: 0, name: "Player 1", life: 20, color: .systemBlue),
        Player(id: 1, name: "Player 2", life: 20, color: .systemRed),
        Player(id: 2, name: "Player 3", life: 20, color: .systemGreen),
        Player(id: 3, name: "Player 4", life: 20, color: .systemOrange)
    ]
    @State private var loserMessages: [String] = []
    @State private var history: [String] = []
    @State private var showHistory = false
    @State private var gameStarted = false
    @State private var nextId = 4  // Start with ID 4 since we have 4 players
    
    let backgroundColor = Color(.systemBackground)
    let accentColor = Color(.systemBlue)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Top bar with title and buttons
                    HStack {
                        if !showHistory {
                            Button("Add Player") {
                                if players.count < 8 && !gameStarted {
                                    addPlayer()
                                }
                            }
                            .disabled(players.count >= 8 || gameStarted)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Text("Life Counter")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(showHistory ? "Back" : "History") {
                                showHistory.toggle()
                            }
                            .padding(.horizontal)
                        } else {
                            Button("Back") {
                                showHistory = false
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Text("Game History")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("Reset") {
                                resetGame()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    
                    // Main content
                    if showHistory {
                        // History view
                        if history.isEmpty {
                            Text("No game history yet")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        } else {
                            List {
                                ForEach(history, id: \.self) { event in
                                    Text(event)
                                }
                            }
                        }
                    } else {
                        // Players view
                        if geometry.size.width > geometry.size.height {
                            // Landscape layout
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: geometry.size.width * 0.05) {
                                    ForEach(players) { player in
                                        playerView(
                                            player: player,
                                            geometry: geometry,
                                            isLandscape: true
                                        )
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                                
                                // Loser messages
                                ForEach(loserMessages, id: \.self) { message in
                                    Text(message)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .padding(.vertical, 10)
                                }
                            }
                        } else {
                            // Portrait layout
                            ScrollView {
                                VStack(spacing: geometry.size.height * 0.04) {
                                    ForEach(players) { player in
                                        playerView(
                                            player: player,
                                            geometry: geometry,
                                            isLandscape: false
                                        )
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                                
                                // Loser messages
                                ForEach(loserMessages, id: \.self) { message in
                                    Text(message)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
    private func playerView(player: Player, geometry: GeometryProxy, isLandscape: Bool) -> some View {
        let buttonSize = isLandscape ?
            min(geometry.size.width * 0.06, 50) :
            min(geometry.size.width * 0.12, 50)
        
        let fontSize = isLandscape ?
            min(geometry.size.width * 0.06, 48) :
            min(geometry.size.width * 0.15, 60)
        
        return VStack(spacing: 12) {
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(player.color))
            
            Text("\(player.life)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding()
                .frame(minWidth: fontSize * 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
            
            HStack(spacing: isLandscape ? 10 : 15) {
                buttonView(title: "+1", action: {
                    updateLife(for: player, by: 1)
                }, size: buttonSize)
                
                buttonView(title: "-1", action: {
                    updateLife(for: player, by: -1)
                }, size: buttonSize)
            }
            
            // Custom amount controls
            HStack {
                CustomAmountView(
                    player: player,
                    onLifeChange: { amount in
                        updateLife(for: player, by: amount)
                    },
                    buttonSize: buttonSize,
                    isLandscape: isLandscape
                )
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
    
    // Add a new player
    private func addPlayer() {
        let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemIndigo, .systemYellow]
        let newPlayer = Player(
            id: nextId,
            name: "Player \(nextId + 1)",
            life: 20,
            color: colors[nextId % colors.count]
        )
        players.append(newPlayer)
        nextId += 1
    }
    
    // Update life total
    private func updateLife(for player: Player, by amount: Int) {
        if !gameStarted && amount != 0 {
            gameStarted = true
        }
        
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].life += amount
            
            // Add to history
            let directionWord = amount > 0 ? "gained" : "lost"
            history.append("\(players[index].name) \(directionWord) \(abs(amount)) life.")
            
            checkForLosers()
        }
    }
    
    private func checkForLosers() {
        loserMessages = []
        for player in players {
            if player.life <= 0 {
                loserMessages.append("\(player.name) LOSES!")
            }
        }
        
        if loserMessages.count == players.count - 1 {
            if let winner = players.first(where: { $0.life > 0 }) {
                history.append("\(winner.name) wins the game!")
                gameStarted = false
            }
        }
    }
    
    // Reset game
    private func resetGame() {
        let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemIndigo, .systemYellow]
        players = [
            Player(id: 0, name: "Player 1", life: 20, color: colors[0]),
            Player(id: 1, name: "Player 2", life: 20, color: colors[1]),
            Player(id: 2, name: "Player 3", life: 20, color: colors[2]),
            Player(id: 3, name: "Player 4", life: 20, color: colors[3])
        ]
        loserMessages = []
        history = []
        gameStarted = false
        nextId = 4
    }
}

struct Player: Identifiable {
    let id: Int
    var name: String
    var life: Int
    let color: UIColor
}

struct CustomAmountView: View {
    let player: Player
    let onLifeChange: (Int) -> Void
    let buttonSize: CGFloat
    let isLandscape: Bool
    
    @State private var customAmount: String = "5"
    
    var body: some View {
        HStack(spacing: isLandscape ? 5 : 10) {
            TextField("5", text: $customAmount)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: buttonSize * 1.5)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button(action: {
                if let amount = Int(customAmount), amount > 0 {
                    onLifeChange(-amount)
                }
            }) {
                Text("-")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: buttonSize * 1.5, height: buttonSize)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(player.color))
                    )
            }
            
            Button(action: {
                if let amount = Int(customAmount), amount > 0 {
                    onLifeChange(amount)
                }
            }) {
                Text("+")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: buttonSize * 1.5, height: buttonSize)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(player.color))
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}
