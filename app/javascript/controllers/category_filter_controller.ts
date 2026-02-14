import { Controller } from "@hotwired/stimulus"

export default class extends Controller<HTMLElement> {
  static targets = ["categoryBtn", "toolsContainer"]
  static values = {
    selected: Number
  }

  declare readonly categoryBtnTargets: HTMLButtonElement[]
  declare readonly toolsContainerTarget: HTMLElement
  declare selectedValue: number

  connect(): void {
    // Load first category's tools on page load
    if (this.selectedValue) {
      this.loadTools(this.selectedValue)
    }
  }

  selectCategory(event: Event): void {
    const button = event.currentTarget as HTMLButtonElement
    const categoryId = button.dataset.categoryId
    
    if (!categoryId) return

    // Update selected state
    this.selectedValue = parseInt(categoryId)
    
    // Update button styles
    this.categoryBtnTargets.forEach(btn => {
      if (btn.dataset.categoryId === categoryId) {
        btn.classList.remove('border-border', 'hover:border-primary', 'hover:bg-surface-elevated')
        btn.classList.add('bg-primary/10', 'border-primary')
      } else {
        btn.classList.remove('bg-primary/10', 'border-primary')
        btn.classList.add('border-border', 'hover:border-primary', 'hover:bg-surface-elevated')
      }
    })

    // Load tools for selected category
    this.loadTools(parseInt(categoryId))
  }

  private loadTools(categoryId: number): void {
    // Show loading state
    this.toolsContainerTarget.innerHTML = `
      <div class="text-center py-12">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-primary/10 border-2 border-primary/30 rounded-2xl mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary animate-spin">
            <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
          </svg>
        </div>
        <p class="text-secondary">加载中...</p>
      </div>
    `

    // Fetch tools via Turbo
    const url = `/categories/${categoryId}/tools`
    fetch(url, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.toolsContainerTarget.innerHTML = html
    })
    .catch(error => {
      console.error('Error loading tools:', error)
      this.toolsContainerTarget.innerHTML = `
        <div class="text-center py-12">
          <p class="text-secondary">加载失败，请稍后重试</p>
        </div>
      `
    })
  }
}
