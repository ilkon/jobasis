import { Controller } from 'stimulus'

export default class extends Controller {
  select(event) {
    const skillIds = Array.from(event.currentTarget.querySelectorAll('option:checked'),e => e.value)

    this.chartController.select(skillIds)
  }

  get chartController() {
    const chart = document.getElementById('chart')
    return this.application.getControllerForElementAndIdentifier(chart, 'trends--chart')
  }
}
