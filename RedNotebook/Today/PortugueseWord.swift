import AVFoundation
import SwiftUI

/// A European Portuguese word for every day, with an example sentence and translations.
struct PortugueseWord {
    let word: String
    let meaning: String
    let sentence: String
    let translation: String

    /// The word for a given day. Each day of the year gets its own, so flipping back works as review.
    static func of(_ day: Date) -> PortugueseWord {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: day) ?? 1
        return all[(dayOfYear - 1) % all.count]
    }

    // European Portuguese (Portugal), with a few Porto favourites.
    static let all: [PortugueseWord] = [
        .init(word: "saudade", meaning: "a deep longing for someone or something you love", sentence: "Tenho saudades de casa.", translation: "I miss home."),
        .init(word: "bom dia", meaning: "good morning", sentence: "Bom dia! Dormiste bem?", translation: "Good morning! Did you sleep well?"),
        .init(word: "obrigada", meaning: "thank you (said by a woman)", sentence: "Obrigada pela ajuda!", translation: "Thank you for the help!"),
        .init(word: "pequeno-almoço", meaning: "breakfast", sentence: "Hoje o pequeno-almoço foi um pastel de nata.", translation: "Today breakfast was a custard tart."),
        .init(word: "café", meaning: "coffee; café", sentence: "Vamos tomar um café?", translation: "Shall we have a coffee?"),
        .init(word: "chuva", meaning: "rain", sentence: "Está a chover muito no Porto.", translation: "It's raining a lot in Porto."),
        .init(word: "sol", meaning: "sun", sentence: "Hoje está sol.", translation: "It's sunny today."),
        .init(word: "amiga", meaning: "friend (female)", sentence: "A minha amiga vem jantar.", translation: "My friend is coming for dinner."),
        .init(word: "trabalho", meaning: "work", sentence: "Tenho muito trabalho esta semana.", translation: "I have a lot of work this week."),
        .init(word: "cansada", meaning: "tired (female)", sentence: "Estou cansada, vou dormir cedo.", translation: "I'm tired, I'll go to bed early."),
        .init(word: "feliz", meaning: "happy", sentence: "Hoje estou muito feliz.", translation: "Today I'm very happy."),
        .init(word: "rua", meaning: "street", sentence: "Moro numa rua tranquila.", translation: "I live on a quiet street."),
        .init(word: "autocarro", meaning: "bus", sentence: "Apanhei o autocarro para a faculdade.", translation: "I took the bus to university."),
        .init(word: "comboio", meaning: "train", sentence: "O comboio para Lisboa sai às dez.", translation: "The train to Lisbon leaves at ten."),
        .init(word: "mar", meaning: "sea", sentence: "Gosto de caminhar junto ao mar.", translation: "I like walking by the sea."),
        .init(word: "praia", meaning: "beach", sentence: "No domingo vamos à praia.", translation: "On Sunday we're going to the beach."),
        .init(word: "livro", meaning: "book", sentence: "Estou a ler um livro novo.", translation: "I'm reading a new book."),
        .init(word: "casa", meaning: "house; home", sentence: "Cheguei a casa às oito.", translation: "I got home at eight."),
        .init(word: "cozinhar", meaning: "to cook", sentence: "Hoje vou cozinhar sopa.", translation: "Today I'm going to make soup."),
        .init(word: "jantar", meaning: "dinner; to have dinner", sentence: "Queres jantar comigo?", translation: "Do you want to have dinner with me?"),
        .init(word: "almoço", meaning: "lunch", sentence: "O almoço está pronto.", translation: "Lunch is ready."),
        .init(word: "água", meaning: "water", sentence: "Bebe mais água!", translation: "Drink more water!"),
        .init(word: "pão", meaning: "bread", sentence: "Comprei pão fresco na padaria.", translation: "I bought fresh bread at the bakery."),
        .init(word: "hoje", meaning: "today", sentence: "Hoje é um bom dia.", translation: "Today is a good day."),
        .init(word: "amanhã", meaning: "tomorrow", sentence: "Até amanhã!", translation: "See you tomorrow!"),
        .init(word: "ontem", meaning: "yesterday", sentence: "Ontem fui ao cinema.", translation: "Yesterday I went to the cinema."),
        .init(word: "semana", meaning: "week", sentence: "Esta semana passou depressa.", translation: "This week went by fast."),
        .init(word: "fim de semana", meaning: "weekend", sentence: "Bom fim de semana!", translation: "Have a good weekend!"),
        .init(word: "telemóvel", meaning: "mobile phone", sentence: "Esqueci-me do telemóvel em casa.", translation: "I forgot my phone at home."),
        .init(word: "estudar", meaning: "to study", sentence: "Preciso de estudar para o exame.", translation: "I need to study for the exam."),
        .init(word: "tese", meaning: "thesis", sentence: "Estou a escrever a minha tese.", translation: "I'm writing my thesis."),
        .init(word: "devagar", meaning: "slowly", sentence: "Pode falar mais devagar, por favor?", translation: "Could you speak more slowly, please?"),
        .init(word: "desculpe", meaning: "excuse me; sorry (polite)", sentence: "Desculpe, onde fica a estação?", translation: "Excuse me, where is the station?"),
        .init(word: "por favor", meaning: "please", sentence: "Um galão, por favor.", translation: "A milky coffee, please."),
        .init(word: "a conta", meaning: "the bill", sentence: "A conta, por favor.", translation: "The bill, please."),
        .init(word: "quanto custa", meaning: "how much is it", sentence: "Quanto custa este livro?", translation: "How much is this book?"),
        .init(word: "frio", meaning: "cold", sentence: "Está frio hoje, leva um casaco.", translation: "It's cold today, take a coat."),
        .init(word: "calor", meaning: "heat; hot weather", sentence: "Que calor!", translation: "It's so hot!"),
        .init(word: "vento", meaning: "wind", sentence: "Há muito vento na praia.", translation: "It's very windy at the beach."),
        .init(word: "nuvem", meaning: "cloud", sentence: "O céu está cheio de nuvens.", translation: "The sky is full of clouds."),
        .init(word: "flor", meaning: "flower", sentence: "Comprei flores para a mesa.", translation: "I bought flowers for the table."),
        .init(word: "gato", meaning: "cat", sentence: "O gato está a dormir no sofá.", translation: "The cat is sleeping on the sofa."),
        .init(word: "cão", meaning: "dog", sentence: "O cão do vizinho é muito simpático.", translation: "The neighbour's dog is very friendly."),
        .init(word: "bonito", meaning: "beautiful; nice", sentence: "Que dia bonito!", translation: "What a beautiful day!"),
        .init(word: "delicioso", meaning: "delicious", sentence: "Este bolo está delicioso.", translation: "This cake is delicious."),
        .init(word: "gosto", meaning: "I like", sentence: "Gosto muito de chá.", translation: "I really like tea."),
        .init(word: "adoro", meaning: "I love", sentence: "Adoro o Porto à noite.", translation: "I love Porto at night."),
        .init(word: "viagem", meaning: "trip; journey", sentence: "Boa viagem!", translation: "Have a good trip!"),
        .init(word: "mala", meaning: "suitcase; bag", sentence: "Já fiz a mala.", translation: "I've already packed my suitcase."),
        .init(word: "aeroporto", meaning: "airport", sentence: "Vou buscar-te ao aeroporto.", translation: "I'll pick you up at the airport."),
        .init(word: "ponte", meaning: "bridge", sentence: "A ponte D. Luís é linda ao pôr do sol.", translation: "The Dom Luís bridge is beautiful at sunset."),
        .init(word: "pôr do sol", meaning: "sunset", sentence: "Vimos o pôr do sol no Jardim do Morro.", translation: "We watched the sunset at Jardim do Morro."),
        .init(word: "rio", meaning: "river", sentence: "Passeámos ao longo do rio Douro.", translation: "We walked along the Douro river."),
        .init(word: "saudável", meaning: "healthy", sentence: "Quero comer de forma mais saudável.", translation: "I want to eat more healthily."),
        .init(word: "ginásio", meaning: "gym", sentence: "Fui ao ginásio depois das aulas.", translation: "I went to the gym after class."),
        .init(word: "dormir", meaning: "to sleep", sentence: "Preciso de dormir oito horas.", translation: "I need to sleep eight hours."),
        .init(word: "sonho", meaning: "dream", sentence: "Tive um sonho estranho.", translation: "I had a strange dream."),
        .init(word: "música", meaning: "music; song", sentence: "Esta música lembra-me o verão.", translation: "This song reminds me of summer."),
        .init(word: "festa", meaning: "party", sentence: "Há uma festa no sábado.", translation: "There's a party on Saturday."),
        .init(word: "aniversário", meaning: "birthday", sentence: "Feliz aniversário!", translation: "Happy birthday!"),
        .init(word: "presente", meaning: "gift; present", sentence: "Comprei um presente para a minha mãe.", translation: "I bought a gift for my mother."),
        .init(word: "família", meaning: "family", sentence: "Liguei à minha família.", translation: "I called my family."),
        .init(word: "mãe", meaning: "mother", sentence: "A minha mãe faz o melhor bolo.", translation: "My mother makes the best cake."),
        .init(word: "pai", meaning: "father", sentence: "O meu pai gosta de futebol.", translation: "My father likes football."),
        .init(word: "irmã", meaning: "sister", sentence: "A minha irmã vem visitar-me.", translation: "My sister is coming to visit me."),
        .init(word: "vizinho", meaning: "neighbour", sentence: "O meu vizinho toca guitarra.", translation: "My neighbour plays the guitar."),
        .init(word: "mercado", meaning: "market", sentence: "Comprei fruta no Mercado do Bolhão.", translation: "I bought fruit at the Bolhão Market."),
        .init(word: "fruta", meaning: "fruit", sentence: "Como fruta todos os dias.", translation: "I eat fruit every day."),
        .init(word: "laranja", meaning: "orange", sentence: "Este sumo de laranja é natural.", translation: "This orange juice is freshly squeezed."),
        .init(word: "sumo", meaning: "juice", sentence: "Um sumo de maçã, por favor.", translation: "An apple juice, please."),
        .init(word: "chá", meaning: "tea", sentence: "Vou fazer um chá.", translation: "I'm going to make some tea."),
        .init(word: "açúcar", meaning: "sugar", sentence: "Sem açúcar, obrigada.", translation: "No sugar, thank you."),
        .init(word: "cedo", meaning: "early", sentence: "Acordei cedo hoje.", translation: "I woke up early today."),
        .init(word: "boa tarde", meaning: "good afternoon", sentence: "Boa tarde! Tudo bem?", translation: "Good afternoon! All good?"),
        .init(word: "boa noite", meaning: "good evening; good night", sentence: "Boa noite e dorme bem.", translation: "Good night and sleep well."),
        .init(word: "agora", meaning: "now", sentence: "Agora não posso, estou ocupada.", translation: "I can't right now, I'm busy."),
        .init(word: "depois", meaning: "after; later", sentence: "Falamos depois.", translation: "We'll talk later."),
        .init(word: "sempre", meaning: "always", sentence: "Estou sempre a aprender.", translation: "I'm always learning."),
        .init(word: "nunca", meaning: "never", sentence: "Nunca é tarde para aprender.", translation: "It's never too late to learn."),
        .init(word: "aprender", meaning: "to learn", sentence: "Estou a aprender português.", translation: "I'm learning Portuguese."),
        .init(word: "palavra", meaning: "word", sentence: "Aprendi uma palavra nova hoje.", translation: "I learned a new word today."),
        .init(word: "perceber", meaning: "to understand", sentence: "Não percebi, pode repetir?", translation: "I didn't understand, could you repeat?"),
        .init(word: "falar", meaning: "to speak", sentence: "Falo um pouco de português.", translation: "I speak a little Portuguese."),
        .init(word: "ajudar", meaning: "to help", sentence: "Posso ajudar?", translation: "Can I help?"),
        .init(word: "esperar", meaning: "to wait; to hope", sentence: "Espera por mim!", translation: "Wait for me!"),
        .init(word: "pensar", meaning: "to think", sentence: "Estou a pensar em ti.", translation: "I'm thinking of you."),
        .init(word: "lembrar", meaning: "to remember; to remind", sentence: "Lembra-te de beber água.", translation: "Remember to drink water."),
        .init(word: "esquecer", meaning: "to forget", sentence: "Não te esqueças da reunião.", translation: "Don't forget the meeting."),
        .init(word: "reunião", meaning: "meeting", sentence: "A reunião começa às dez.", translation: "The meeting starts at ten."),
        .init(word: "prazo", meaning: "deadline", sentence: "O prazo é na sexta-feira.", translation: "The deadline is on Friday."),
        .init(word: "conseguir", meaning: "to manage; to be able to", sentence: "Consegui acabar o capítulo!", translation: "I managed to finish the chapter!"),
        .init(word: "orgulhosa", meaning: "proud (female)", sentence: "Estou orgulhosa de mim.", translation: "I'm proud of myself."),
        .init(word: "calma", meaning: "calm", sentence: "Tem calma, vai correr bem.", translation: "Stay calm, it'll go well."),
        .init(word: "sorte", meaning: "luck", sentence: "Boa sorte no exame!", translation: "Good luck on the exam!"),
        .init(word: "coragem", meaning: "courage", sentence: "Força e coragem!", translation: "Strength and courage!"),
        .init(word: "força", meaning: "strength; come on, you can do it", sentence: "Força, tu consegues!", translation: "Come on, you can do it!"),
        .init(word: "sossego", meaning: "peace and quiet", sentence: "Que sossego aqui no jardim.", translation: "It's so peaceful here in the garden."),
        .init(word: "desenrascar", meaning: "to find a way out, to improvise", sentence: "Ela desenrasca-se sempre.", translation: "She always finds a way."),
        .init(word: "petiscos", meaning: "small shared dishes, like tapas", sentence: "Vamos aos petiscos esta noite?", translation: "Shall we go for petiscos tonight?"),
        .init(word: "tasca", meaning: "small traditional tavern", sentence: "Jantámos numa tasca pequena.", translation: "We had dinner in a little tavern."),
        .init(word: "azulejo", meaning: "painted ceramic tile", sentence: "Adoro os azulejos da estação de São Bento.", translation: "I love the tiles at São Bento station."),
        .init(word: "miradouro", meaning: "viewpoint", sentence: "Subimos ao miradouro para ver a cidade.", translation: "We climbed up to the viewpoint to see the city."),
        .init(word: "esplanada", meaning: "outdoor café terrace", sentence: "Vamos sentar-nos na esplanada.", translation: "Let's sit on the terrace."),
        .init(word: "lanche", meaning: "afternoon snack", sentence: "O lanche foi chá e torradas.", translation: "My afternoon snack was tea and toast."),
        .init(word: "torrada", meaning: "toast", sentence: "Uma torrada e um galão, por favor.", translation: "Toast and a milky coffee, please."),
        .init(word: "galão", meaning: "milky coffee served in a glass", sentence: "Um galão morno, por favor.", translation: "A warm galão, please."),
        .init(word: "cimbalino", meaning: "an espresso, the Porto way", sentence: "No Porto, um café é um cimbalino.", translation: "In Porto, an espresso is a cimbalino."),
        .init(word: "fixe", meaning: "cool (informal)", sentence: "Que fixe!", translation: "How cool!"),
        .init(word: "giro", meaning: "cute; pretty", sentence: "Que caderno tão giro!", translation: "What a cute notebook!"),
        .init(word: "bué", meaning: "a lot (slang)", sentence: "Gosto bué disto.", translation: "I like this a lot."),
        .init(word: "tranquilo", meaning: "calm; no worries", sentence: "Está tudo tranquilo.", translation: "Everything's fine."),
        .init(word: "estrela", meaning: "star", sentence: "Hoje veem-se muitas estrelas.", translation: "You can see lots of stars tonight."),
        .init(word: "lua", meaning: "moon", sentence: "A lua está cheia.", translation: "The moon is full."),
        .init(word: "outono", meaning: "autumn", sentence: "Gosto das cores do outono.", translation: "I like the colours of autumn."),
        .init(word: "inverno", meaning: "winter", sentence: "No inverno bebo chá todos os dias.", translation: "In winter I drink tea every day."),
        .init(word: "primavera", meaning: "spring", sentence: "Na primavera há flores por todo o lado.", translation: "In spring there are flowers everywhere."),
        .init(word: "verão", meaning: "summer", sentence: "No verão vamos para o Algarve.", translation: "In summer we're going to the Algarve."),
        .init(word: "castanhas", meaning: "chestnuts", sentence: "Cheira a castanhas assadas na rua.", translation: "The street smells of roasted chestnuts."),
        .init(word: "guarda-chuva", meaning: "umbrella", sentence: "Não te esqueças do guarda-chuva.", translation: "Don't forget your umbrella."),
        .init(word: "passear", meaning: "to go for a walk, to stroll", sentence: "Fomos passear pela Ribeira.", translation: "We went for a stroll along the Ribeira."),
    ]
}

/// Reads Portuguese aloud with a Portugal (pt-PT) voice.
@MainActor
enum PortugueseSpeaker {
    private static let synthesizer = AVSpeechSynthesizer()

    static func say(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-PT")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85 // a little slower, for learning
        synthesizer.speak(utterance)
    }
}

/// "Palavra do dia": an index card at the bottom of each day's page.
struct PortugueseWordCard: View {
    let day: Date

    var body: some View {
        let entry = PortugueseWord.of(day)

        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("PALAVRA DO DIA · 🇵🇹")
                    .font(Theme.eyebrow)
                    .tracking(1.5)
                    .foregroundStyle(PortugueseHolidays.color)
                Spacer()
                Button {
                    PortugueseSpeaker.say("\(entry.word). \(entry.sentence)")
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PortugueseHolidays.color)
                        .frame(width: 32, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hear it in Portuguese")
            }

            Text(entry.word)
                .font(Theme.serif(24, .semibold))
                .foregroundStyle(Theme.ink)
            Text(entry.meaning)
                .font(Theme.serif(13).italic())
                .foregroundStyle(Theme.inkSecondary)

            Rectangle().fill(Theme.hairline).frame(height: 0.5).padding(.vertical, 2)

            Text(entry.sentence)
                .font(Theme.handwriting(size: 21))
                .foregroundStyle(Theme.ink)
            Text(entry.translation)
                .font(Theme.serif(12))
                .foregroundStyle(Theme.inkTertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // An index card: white with faint blue lines and a red margin line
            ZStack(alignment: .topLeading) {
                Rectangle().fill(Color(red: 1.0, green: 0.995, blue: 0.98))
                VStack(spacing: 22) {
                    ForEach(0..<8) { _ in Rectangle().fill(Color(red: 0.55, green: 0.70, blue: 0.85).opacity(0.18)).frame(height: 0.7) }
                }
                .padding(.top, 34)
                Rectangle().fill(Color(red: 0.92, green: 0.45, blue: 0.45).opacity(0.35)).frame(height: 0.8).padding(.top, 30)
            }
            .clipped()
            .shadow(color: .black.opacity(0.12), radius: 2, x: 1, y: 1.5)
        )
        // Held on with a strip of washi tape
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PortugueseHolidays.color.opacity(0.35))
                .frame(width: 64, height: 16)
                .rotationEffect(.degrees(-4))
                .offset(y: -8)
        }
        .rotationEffect(.degrees(-0.6))
    }
}
