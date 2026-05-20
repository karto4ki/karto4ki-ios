import UIKit

final class QuizViewController: UIViewController {

    // MARK: - Config

    private let deck: LibraryModels.DeckSet
    private let session: StudySessionAPI
    private let cardService: CardServiceProtocol

    // MARK: - Questions (built client-side from session cards)

    private struct Question {
        let cardId: String
        let sessionId: String
        let front: String
        let options: [String]
        let correctIndex: Int
    }

    private var questions: [Question] = []

    // MARK: - State

    var onFinished: (() -> Void)?

    private var currentIndex = 0
    private var correctCount = 0
    private var questionStartDate = Date()
    private var isAnswering = false
    private var submitTask: Task<Void, Never>?

    // MARK: - Colors

    private let accentPurple   = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let correctGreen   = UIColor(red: 0.18, green: 0.78, blue: 0.45, alpha: 1)
    private let wrongRed       = UIColor(red: 0.92, green: 0.28, blue: 0.36, alpha: 1)
    private let glassCorner: CGFloat = 22

    // MARK: - Top bar

    private let backButton      = UIButton(type: .system)
    private let counterLabel    = UILabel()
    private let progressBar     = UIProgressView(progressViewStyle: .bar)

    // MARK: - Question card

    private let questionCard    = UIView()
    private let questionLabel   = UILabel()

    // MARK: - Option buttons

    private let optionButtons   = (0..<4).map { _ in MultilineButton() }
    private let optionsGrid     = UIStackView()

    // MARK: - Results overlay

    private let resultsView     = UIView()

    // MARK: - Init

    init(deck: LibraryModels.DeckSet, session: StudySessionAPI, cardService: CardServiceProtocol) {
        self.deck = deck
        self.session = session
        self.cardService = cardService
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        questions = Self.buildQuestions(from: session.cards, sessionId: session.id)
        configureBackground()
        configureTopBar()
        configureQuestionCard()
        configureOptionsGrid()
        configureResultsView()
        if questions.isEmpty {
            dismiss(animated: true)
        } else {
            showQuestion(at: 0, animated: false)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        submitTask?.cancel()
    }

    // MARK: - Build questions client-side

    private static func buildQuestions(from cards: [CardAPI], sessionId: String) -> [Question] {
        guard cards.count >= 2 else { return [] }
        let allBacks = cards.map { $0.back }
        return cards.map { card in
            let correct = card.back
            let distractors = allBacks
                .filter { $0 != correct }
                .shuffled()
                .prefix(3)
            var options = [correct] + distractors
            options.shuffle()
            let correctIndex = options.firstIndex(of: correct) ?? 0
            return Question(
                cardId: card.id,
                sessionId: sessionId,
                front: card.front,
                options: options,
                correctIndex: correctIndex
            )
        }
    }

    // MARK: - Layout

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
    }

    private func configureTopBar() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        backButton.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        counterLabel.font = Fonts.futuraB17
        counterLabel.textColor = .white
        counterLabel.textAlignment = .right

        progressBar.progressTintColor = accentPurple
        progressBar.trackTintColor = UIColor.white.withAlphaComponent(0.22)
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true

        backButton.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        view.addSubview(counterLabel)
        view.addSubview(progressBar)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            counterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            counterLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            progressBar.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func configureQuestionCard() {
        questionCard.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        questionCard.layer.cornerRadius = glassCorner
        questionCard.layer.borderWidth = 1
        questionCard.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor

        questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        questionLabel.textColor = .white
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

        questionCard.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.centerYAnchor.constraint(equalTo: questionCard.centerYAnchor),
            questionLabel.topAnchor.constraint(greaterThanOrEqualTo: questionCard.topAnchor, constant: 24),
            questionLabel.bottomAnchor.constraint(lessThanOrEqualTo: questionCard.bottomAnchor, constant: -24),
            questionLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20)
        ])

        questionCard.translatesAutoresizingMaskIntoConstraints = false
        questionCard.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.addSubview(questionCard)
        NSLayoutConstraint.activate([
            questionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionCard.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 24)
        ])
    }

    private func configureOptionsGrid() {
        optionsGrid.axis = .vertical
        optionsGrid.spacing = 10
        optionsGrid.distribution = .fill

        for (i, btn) in optionButtons.enumerated() {
            btn.tag = i
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            btn.layer.cornerRadius = 18
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionsGrid.addArrangedSubview(btn)
        }

        optionsGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsGrid)
        NSLayoutConstraint.activate([
            optionsGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionsGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            optionsGrid.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 20)
        ])
    }

    private func configureResultsView() {
        resultsView.alpha = 0
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultsView)
        resultsView.pin(to: view)
    }

    // MARK: - Quiz logic

    private func showQuestion(at index: Int, animated: Bool) {
        guard index < questions.count else { return }
        let q = questions[index]

        let total = questions.count
        counterLabel.text = L10n.Quiz.questionCounter(index + 1, total)
        progressBar.setProgress(Float(index) / Float(total), animated: animated)

        questionLabel.text = q.front

        for (i, btn) in optionButtons.enumerated() {
            btn.setTitle(i < q.options.count ? q.options[i] : "", for: .normal)
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            btn.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
            btn.isEnabled = true
            btn.alpha = 1
        }

        isAnswering = false
        questionStartDate = Date()

        if animated {
            questionCard.alpha = 0
            optionsGrid.alpha = 0
            UIView.animate(withDuration: 0.22) {
                self.questionCard.alpha = 1
                self.optionsGrid.alpha = 1
            }
        }
    }

    @objc private func optionTapped(_ sender: UIButton) {
        guard !isAnswering else { return }
        isAnswering = true

        let selectedIndex = sender.tag
        let question = questions[currentIndex]
        let correctIndex = question.correctIndex
        let isCorrect = selectedIndex == correctIndex
        let elapsed = Int(Date().timeIntervalSince(questionStartDate) * 1000)

        applyAnswerFeedback(selectedIndex: selectedIndex, correctIndex: correctIndex)
        if isCorrect { correctCount += 1 }

        // Submit answer via study endpoint in background
        let sessionId = question.sessionId
        let cardId = question.cardId
        submitTask = Task {
            try? await cardService.submitAnswer(
                sessionId: sessionId,
                cardId: cardId,
                isCorrect: isCorrect,
                timeSpentMs: elapsed
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.advanceToNext()
        }
    }

    private func applyAnswerFeedback(selectedIndex: Int, correctIndex: Int) {
        for (i, btn) in optionButtons.enumerated() {
            btn.isEnabled = false
            if i == correctIndex {
                btn.backgroundColor = correctGreen.withAlphaComponent(0.75)
                btn.layer.borderColor = correctGreen.cgColor
            } else if i == selectedIndex {
                btn.backgroundColor = wrongRed.withAlphaComponent(0.75)
                btn.layer.borderColor = wrongRed.cgColor
            } else {
                btn.alpha = 0.4
            }
        }
    }

    private func advanceToNext() {
        currentIndex += 1
        if currentIndex < questions.count {
            showQuestion(at: currentIndex, animated: true)
        } else {
            finishQuiz()
        }
    }

    private func finishQuiz() {
        progressBar.setProgress(1.0, animated: true)
        let correct = correctCount
        let total = questions.count
        let pct = Float(correct) / Float(max(total, 1)) * 100

        AppCacheStore.invalidateCards(setId: deck.id.uuidString.lowercased())
        AppCacheStore.invalidateSets()
        onFinished?()

        showResults(correct: correct, total: total, pct: pct)
    }

    // MARK: - Results

    private func showResults(correct: Int, total: Int, pct: Float) {
        buildResultsContent(correct: correct, total: total, pct: pct)
        UIView.animate(withDuration: 0.35) {
            self.resultsView.alpha = 1
            self.questionCard.alpha = 0
            self.optionsGrid.alpha = 0
            self.backButton.alpha = 0
            self.counterLabel.alpha = 0
        }
    }

    private func buildResultsContent(correct: Int, total: Int, pct: Float) {
        resultsView.subviews.forEach { $0.removeFromSuperview() }

        let scoreLabel = UILabel()
        scoreLabel.text = L10n.Quiz.scorePct(pct)
        scoreLabel.font = UIFont.systemFont(ofSize: 72, weight: .black)
        scoreLabel.textColor = pct >= 70 ? correctGreen : (pct >= 40 ? .white : wrongRed)
        scoreLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.Quiz.correctOf(correct, total)
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.textAlignment = .center

        let retryBtn = makeResultButton(
            title: L10n.Quiz.retry,
            background: accentPurple.withAlphaComponent(0.55),
            borderColor: UIColor.white.withAlphaComponent(0.45)
        )
        retryBtn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let closeBtn = makeResultButton(
            title: L10n.Common.done,
            background: .clear,
            borderColor: UIColor.white.withAlphaComponent(0.55)
        )
        closeBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [scoreLabel, subtitleLabel, retryBtn, closeBtn])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.setCustomSpacing(8, after: scoreLabel)
        stack.setCustomSpacing(36, after: subtitleLabel)

        resultsView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: resultsView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: resultsView.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor, constant: -28)
        ])
    }

    private func makeResultButton(title: String, background: UIColor, borderColor: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = background
        btn.layer.cornerRadius = glassCorner
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = borderColor.cgColor
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }

    // MARK: - Actions

    @objc private func backTapped() {
        submitTask?.cancel()
        dismiss(animated: true)
    }

    @objc private func retryTapped() {
        currentIndex = 0
        correctCount = 0
        isAnswering = false
        // Re-shuffle questions for retry
        questions = Self.buildQuestions(from: session.cards, sessionId: session.id)

        UIView.animate(withDuration: 0.25) {
            self.resultsView.alpha = 0
            self.questionCard.alpha = 1
            self.optionsGrid.alpha = 1
            self.backButton.alpha = 1
            self.counterLabel.alpha = 1
        } completion: { _ in
            self.showQuestion(at: 0, animated: false)
        }
    }
}

// MARK: - MultilineButton

private final class MultilineButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }

    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        guard let label = titleLabel else { return super.intrinsicContentSize }
        let insets = contentEdgeInsets
        let availableWidth = bounds.width > 0
            ? bounds.width - insets.left - insets.right
            : UIScreen.main.bounds.width - 40 - insets.left - insets.right
        let labelHeight = label.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).height
        return CGSize(width: UIView.noIntrinsicMetric, height: labelHeight + insets.top + insets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}
