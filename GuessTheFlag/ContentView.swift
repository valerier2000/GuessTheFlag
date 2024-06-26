//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Valeriia Rohatynska on 02/04/2024.
//

import SwiftUI

struct FlagImage: View {
    var country: String
    
    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct LargeBlueTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.blue)
    }
}

extension View {
    func largeBlueTitleStyle() -> some View {
        modifier(LargeBlueTitle())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    
    @State private var questionCount = 1
    @State private var showingFinalScore = false
    
    @State private var tappedFlag: Int? = nil
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.5, green: 0.8, blue: 0.1), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .largeBlueTitleStyle()
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])                            
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            withAnimation(.bouncy(duration: 1.5)) {
                                tappedFlag = number
                            }
                            
                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number])
                                .rotation3DEffect(.degrees(tappedFlag == number ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                                .opacity(tappedFlag == nil || tappedFlag == number ? 1.0 : 0.25)
                                .scaleEffect(tappedFlag == nil || tappedFlag == number ? 1.0 : 0.8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert("Game over!", isPresented: $showingFinalScore) {
            Button("Restart", action: reset)
        } message: {
            Text("Your final score is \(score)/\(questionCount)")
        }
    }

    func flagTapped(_ number: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if number == correctAnswer {
                scoreTitle = "Correct"
                score += 1
            } else {
                let wrongCountry = countries[number]
                scoreTitle = "Wrong! That's the flag of \(wrongCountry)"
            }
            
            if questionCount < 8 {
                showingScore = true
                questionCount += 1
            } else {
                showingFinalScore = true
            }
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        tappedFlag = nil
    }
    
    func reset() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        score = 0
        questionCount = 1
        showingScore = false
        showingFinalScore = false
        tappedFlag = nil
    }
    
}

#Preview {
    ContentView()
}
