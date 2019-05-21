import { Controller } from 'stimulus'

export default class extends Controller {
  select(event) {
    const skillIds = Array.from(event.currentTarget.querySelectorAll('option:checked'),e => e.value)
    const paths = document.getElementsByTagName('path')

    for (let i = 0; i < paths.length; i++) {
      const skillId = paths[i].getAttribute('skill-id')
      if (skillIds.includes(skillId)) {
        paths[i].classList.add('selected')
        paths[i].parentNode.appendChild(paths[i])
      } else {
        paths[i].classList.remove('selected')
      }
    }
  }
}
