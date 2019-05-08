import { Controller } from 'stimulus'

export default class extends Controller {
  highlight(event) {
    const skillIds = Array.from(event.currentTarget.querySelectorAll('option:checked'),e => e.value);
    const paths = document.getElementsByTagName('path');

    for (let i = 0; i < paths.length; i++) {
      const skillId = paths[i].id.substring(4)
      if (skillIds.includes(skillId)) {
        paths[i].classList.add('highlight')
      } else {
        paths[i].classList.remove('highlight')
      }
    }
  }
}
