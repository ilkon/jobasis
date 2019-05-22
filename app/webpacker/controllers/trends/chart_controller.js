import { Controller } from 'stimulus'
import * as d3 from 'd3'

export default class extends Controller {
  connect() {
    this.chartDates = JSON.parse(this.data.get('dates')).map(x => new Date(x))
    this.chartTrends = JSON.parse(this.data.get('trends'))
    this.chartSkills = JSON.parse(this.data.get('skills'))
    this.chartSelectedSkillIds = JSON.parse(this.data.get('selected-skill-ids'))

    this.draw()

    window.addEventListener('resize', this.draw.bind(this))
  }

  draw() {
    let [canvas, width, height] = this.prepareCanvas()
    this.drawChart(canvas, width, height)
  }

  prepareCanvas() {
    const clientWidth = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)

    let svgWidth = 300
    if (clientWidth >= 1408) { // fullhd
      svgWidth = 890
    } else if (clientWidth >= 1216) { // widescreen
      svgWidth = clientWidth - 480
    } else if (clientWidth >= 1024) { // desktop
      svgWidth = clientWidth - 440
    } else if (clientWidth >= 769) { // tablet
      svgWidth = clientWidth - 380
    } else { // mobile
      svgWidth = clientWidth - 65
    }
    const svgHeight = svgWidth * 0.75

    d3.select(this.element).select('svg').remove()

    let svg = d3.select(this.element)
        .append('svg:svg')
        .attr('width', svgWidth)
        .attr('height', svgHeight)

    const margin = { top: 20, right: 20, bottom: 30, left: 50 }

    let canvas = svg.append('svg:g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    return [canvas, svgWidth - margin.left - margin.right, svgHeight - margin.top - margin.bottom]
  }

  drawChart(canvas, width, height) {
    const dates = this.chartDates,
        trends = this.chartTrends

    let x = d3.scaleTime().rangeRound([0, width])
    let y = d3.scaleLinear().rangeRound([height, 0])

    let line = d3.line()
        .x((d, i) => { return x(dates[i])})
        .y(d => { return y(d)})
        .curve(d3.curveMonotoneX)

    x.domain(d3.extent(dates))
    y.domain(d3.extent([].concat(...Object.values(trends))).map(x => x * 1.075))

    canvas.append('svg:g')
        .attr('transform', 'translate(0,' + height + ')')
        .call(d3.axisBottom(x))
        .select('.domain')

    canvas.append('svg:g')
        .call(d3.axisLeft(y))
        .append('svg:text')
        .attr('fill', '#000')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('dy', '0.71em')
        .attr('text-anchor', 'end')
        .text('Vacancies')

    this.skillGroups = canvas.append('svg:g')

    let div = d3.select('body').append('div')
        .attr('class', 'chart-tooltip')
        .style('opacity', 0);
    let formatDate = d3.timeFormat('%b %Y')

    const _this = this
    for (let [key, value] of Object.entries(trends)) {
      let skillGroup = this.skillGroups
          .append('svg:g')
          .attr('skill-id', key)
          .on('mouseover', function(d) {
            _this.highlight(this)
          })
          .on('mouseout', function(d) {
            _this.unhighlight(this)
          })
          .on('click', function(d) {
            _this.toggleSelected(this)
          })

      skillGroup.append('svg:path')
          .datum(value)
          .attr('d', line)

      skillGroup.selectAll('circle')
          .data(value)
          .enter().append('svg:circle')
          .attr('r', 4)
          .attr('cx', (d, i) => { return x(dates[i])})
          .attr('cy', d => { return y(d)})
          .on('mouseover', function(d, i) {
            div.style('opacity', .9)
            div.html(formatDate(dates[i]) + '<br/><b>' + d + '</b>')
                .style('left', (d3.event.pageX - 30) + 'px')
                .style('top', (d3.event.pageY - 45) + 'px')
          })
          .on('mouseout', function(d) {
            div.style('opacity', 0);
          });
    }

    this.updateSelected(this.chartSelectedSkillIds)
  }

  highlight(el) {
    el.classList.add('highlighted')
    el.parentNode.appendChild(el)
  }

  unhighlight(el) {
    el.classList.remove('highlighted')
    if (!el.classList.contains('selected')) {
      let firstChild = el.parentNode.firstChild
      if (firstChild) {
        el.parentNode.insertBefore(el, firstChild)
      }
    }
  }

  toggleSelected(el) {
    const skillId = el.getAttribute('skill-id')
    el.classList.toggle('selected')

    if (el.classList.contains('selected')) {
      this.chartSelectedSkillIds.push(skillId)
    } else {
      this.chartSelectedSkillIds = this.chartSelectedSkillIds.filter(sId => sId !== skillId)
    }

    this.selectorController.updateSelected(this.chartSelectedSkillIds)
  }

  updateSelected(skillIds) {
    this.skillGroups.selectAll('g').each(function(d, i) {
      const skillId = this.getAttribute('skill-id')
      if (skillIds.includes(skillId)) {
        this.classList.add('selected')
        this.parentNode.appendChild(this)
      } else {
        this.classList.remove('selected')
      }
    })

    this.chartSelectedSkillIds = skillIds
  }

  get selectorController() {
    const chart = document.getElementById('selector')
    return this.application.getControllerForElementAndIdentifier(chart, 'trends--selector')
  }
}
