import { Controller } from "@hotwired/stimulus"

export default class extends Controller<HTMLElement> {
  static targets = ["categoryBtn", "toolsContainer", "childrenContainer"]
  static values = {
    selected: String  // Changed from Number to String to support 'all'
  }

  declare readonly categoryBtnTargets: HTMLButtonElement[]
  declare readonly toolsContainerTarget: HTMLElement
  declare readonly childrenContainerTargets: HTMLElement[]
  declare selectedValue: string

  connect(): void {
    // Load first category's tools on page load
    if (this.selectedValue) {
      if (this.selectedValue === 'all') {
        this.loadAllTools()
      } else {
        this.loadTools(parseInt(this.selectedValue))
      }
    }
  }

  selectCategory(event: Event): void {
    const button = event.currentTarget as HTMLButtonElement
    const categoryId = button.dataset.categoryId
    
    if (!categoryId) return

    // Update selected state
    this.selectedValue = categoryId
    
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
    if (categoryId === 'all') {
      this.loadAllTools()
    } else {
      this.loadTools(parseInt(categoryId))
    }
  }

  toggleChildren(event: Event): void {
    event.stopPropagation()
    const button = event.currentTarget as HTMLButtonElement
    const categoryId = button.dataset.categoryId
    
    if (!categoryId) return

    // Find the children container for this category
    const childrenContainer = this.childrenContainerTargets.find(
      container => container.dataset.parentId === categoryId
    )

    if (!childrenContainer) return

    // Find the icon element
    const icon = button.querySelector('svg')
    if (!icon) return

    // Toggle visibility with animation
    const isHidden = childrenContainer.classList.contains('hidden')
    if (isHidden) {
      // Expand: rotate to down position
      childrenContainer.classList.remove('hidden')
      icon.style.transform = 'rotate(0deg)'
    } else {
      // Collapse: rotate to right position
      childrenContainer.classList.add('hidden')
      icon.style.transform = 'rotate(-90deg)'
    }
  }

  private loadAllTools(): void {
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

    // Fetch all tools via Turbo
    const url = `/categories/all_tools`
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
        console.error('Error loading all tools:', error)
        this.toolsContainerTarget.innerHTML = `
          <div class="text-center py-12">
            <p class="text-secondary">加载失败，请稍后重试</p>
          </div>
        `
      })
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
