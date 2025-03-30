import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["page", "answer", "results"]

  connect() {
    this.currentPageIndex = 0
    this.totalPages = this.pageTargets.length
    this.answers = new Map()

    this.showCurrentPage()
  }

  next() {
    if (this.currentPageIndex < this.totalPages - 1) {
      this.currentPageIndex++
      this.showCurrentPage()
    } else {
      this.showResults()
    }
  }

  previous() {
    if (this.currentPageIndex > 0) {
      this.currentPageIndex--
      this.showCurrentPage()
    }
  }

  selectAnswer(event) {
    const clickedAnswer = event.currentTarget
    const questionPage = clickedAnswer.closest(".quiz-page")

    const answersForThisPage = this.answerTargets.filter(answer =>
      answer.closest(".quiz-page") === questionPage
    )

    answersForThisPage.forEach(answer => answer.classList.remove("selected"))

    const questionIndex = this.currentPageIndex
    const previousSelection = this.answers.get(questionIndex)

    if (previousSelection === clickedAnswer) {
      this.answers.delete(questionIndex)
    } else {
      clickedAnswer.classList.add("selected")
      this.answers.set(questionIndex, clickedAnswer)
    }
  }

  showCurrentPage() {
    this.pageTargets.forEach((page, index) => {
      if (index === this.currentPageIndex) {
        page.style.display = "block"
      } else {
        page.style.display = "none"
      }
    })

    const resultSection = document.getElementById("quiz-results")
    if (resultSection) {
      resultSection.style.display = "none"
    }
  }

  showResults() {
    this.pageTargets.forEach(page => (page.style.display = "none"))
  
    this.resultsTarget.style.display = "block"
  
    this.answers.forEach((answerEl, questionIndex) => {
      const selectedLetter = answerEl.dataset.answerLetter
      const resultCard = document.querySelector(`#quiz-result-${questionIndex + 1}`)
      const answerBlocks = resultCard.querySelectorAll(".quiz-answers-card")
  
      answerBlocks.forEach(block => {
        const blockLetter = block.querySelector(".quiz-answers-letter")?.textContent?.trim()
  
        if (blockLetter === selectedLetter) {
          const label = block.querySelector(".label")
          if (label) label.classList.remove("d-none")
        }
      })
    })
  }
}
