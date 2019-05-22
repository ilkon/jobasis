import { Controller } from 'stimulus'

export default class extends Controller {
  onchange(event) {
    const skillIds = Array.from(event.currentTarget.querySelectorAll('option:checked'),e => e.value)
    this.chartController.updateSelected(skillIds)
  }

  updateSelected(skillIds) {
    let options = this.element.querySelectorAll('option')

    for (let opt of options) {
      opt.selected = skillIds.includes(opt.value)
    }
  }

  get chartController() {
    const chart = document.getElementById('chart')
    return this.application.getControllerForElementAndIdentifier(chart, 'trends--chart')
  }
}
