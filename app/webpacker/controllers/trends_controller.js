import { Controller } from 'stimulus'
import * as d3 from 'd3'

export default class extends Controller {
  connect() {
    this.trendData = JSON.parse(this.data.get('data'))
    this.trendDates = JSON.parse(this.data.get('dates')).map(x => new Date(x))

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

    let canvas = svg.append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    return [canvas, svgWidth - margin.left - margin.right, svgHeight - margin.top - margin.bottom]
  }

  drawChart(canvas, width, height) {
    const data = this.trendData,
        dates = this.trendDates

    let x = d3.scaleTime().rangeRound([0, width])
    let y = d3.scaleLinear().rangeRound([height, 0])

    let line = d3.line()
        .x(function(d, i) { return x(dates[i])})
        .y(function(d) { return y(d)})
        .curve(d3.curveMonotoneX)

    x.domain(d3.extent(dates))
    y.domain(d3.extent([].concat(...Object.values(data))).map(x => x * 1.075))

    canvas.append('g')
        .attr('transform', 'translate(0,' + height + ')')
        .call(d3.axisBottom(x))
        .select('.domain')

    canvas.append('g')
        .call(d3.axisLeft(y))
        .append('text')
        .attr('fill', '#000')
        .attr('transform', 'rotate(-90)')
        .attr('y', 6)
        .attr('dy', '0.71em')
        .attr('text-anchor', 'end')
        .text('Vacancies')

    for (let [key, value] of Object.entries(data)) {
      canvas.append('path')
          .datum(value)
          .attr('fill', 'none')
          .attr('stroke', 'steelblue')
          .attr('stroke-linejoin', 'round')
          .attr('stroke-linecap', 'round')
          .attr('stroke-width', 1.5)
          .attr('d', line)
    }
  }
}
