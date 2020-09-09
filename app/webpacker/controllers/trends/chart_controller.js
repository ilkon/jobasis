import { Controller } from 'stimulus'
import * as d3 from 'd3'

export default class extends Controller {
  connect() {
    this.chartDates = JSON.parse(this.data.get('dates'))
    this.chartTrends = JSON.parse(this.data.get('trends'))
    this.chartSkills = JSON.parse(this.data.get('skills'))
    this.chartSelectedSkillIds = JSON.parse(this.data.get('selected-skill-ids'))

    this.draw()

    window.addEventListener('resize', this.draw.bind(this))
  }

  draw() {
    const [canvas, width, height] = this.prepareCanvas()
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

    d3.select('#chart-tooltip').remove()
    d3.select('body')
        .append('div')
        .attr('id', 'chart-tooltip')
        .style('opacity', 0)
        .style('display', 'none')

    d3.select('#skill-title').remove()
    const skillTitle = d3.select('#chart')
        .append('div')
        .attr('id', 'skill-title')
        .style('width', svgWidth + 'px')
        .style('opacity', 0)
        .style('display', 'none')
    skillTitle.append('div')

    d3.select(this.element).select('svg').remove()

    const svg = d3.select(this.element)
        .append('svg:svg')
        .attr('width', svgWidth)
        .attr('height', svgHeight)

    const margin = { top: 20, right: 40, bottom: 30, left: 40 }

    const canvas = svg.append('svg:g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    return [canvas, svgWidth - margin.left - margin.right, svgHeight - margin.top - margin.bottom]
  }

  drawChart(canvas, width, height) {
    const dates = this.chartDates,
        trends = this.chartTrends

    const x = d3.scaleLinear().rangeRound([0, width])
    const y = d3.scaleLinear().rangeRound([height, 0])

    const line = d3.line()
        .x((d, i) => x(i))
        .y(d => y(d))
        .curve(d3.curveMonotoneX)

    x.domain(d3.extent([0, dates.length - 1]))
    y.domain(d3.extent([].concat(...Object.values(trends))).map(x => x * 1.075))

    const xAxis = d3.axisBottom(x)
        .ticks(dates.length, 's')
        .tickFormat((d, i) => dates[i])
    const yAxis = d3.axisLeft(y)

    canvas.append('svg:g')
        .attr('class', 'axis')
        .attr('transform', 'translate(0,' + height + ')')
        .call(xAxis)
    canvas.append('svg:g')
        .attr('class', 'axis')
        .call(yAxis)
        .append('svg:text')
        .attr('fill', 'currentColor')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('dy', '0.71em')
        .attr('text-anchor', 'end')
        .text('Vacancies')

    this.skillGroups = canvas.append('svg:g')

    const _this = this
    for (let [key, value] of Object.entries(trends)) {
      const skillGroup = this.skillGroups
          .append('svg:g')
          .attr('class', 'skill-group')
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
          .attr('class', 'line-activator')
          .attr('d', line)
      skillGroup.append('svg:path')
          .datum(value)
          .attr('class', 'line')
          .attr('d', line)

      skillGroup.selectAll('circle.node')
          .data(value)
          .enter().append('svg:circle')
          .attr('class', 'node')
          .attr('r', 5)
          .attr('cx', (d, i) => x(i))
          .attr('cy', d => y(d))
          .on('mouseover', function(event, d, i) {
            d3.select('#chart-tooltip')
                .html(dates[i] + '<br/><b>' + d + '</b>')
                .style('left', (event.pageX - 30) + 'px')
                .style('top', (event.pageY - 45) + 'px')
                .transition().duration(100)
                .style('opacity', 1)
                .style('display', 'block')
          })
          .on('mouseout', function(d) {
            d3.select('#chart-tooltip')
                .transition().duration(100)
                .style('opacity', 0)
          })
    }

    this.updateSelected(this.chartSelectedSkillIds)
  }

  highlight(el) {
    const skills = this.chartSkills
    const skillId = el.getAttribute('skill-id')
    el.classList.add('highlighted')
    el.parentNode.appendChild(el)
    d3.select('#skill-title div')
        .html(skills[skillId])
    d3.select('#skill-title')
        .transition().duration(200)
        .style('opacity', 1)
        .style('display', 'block')
  }

  unhighlight(el) {
    el.classList.remove('highlighted')
    if (!el.classList.contains('selected')) {
      const firstChild = el.parentNode.firstChild
      if (firstChild) {
        el.parentNode.insertBefore(el, firstChild)
      }
    }
    d3.select('#skill-title')
        .transition().duration(200)
        .style('opacity', 0)
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
