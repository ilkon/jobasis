// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/webpacker and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()
require('turbolinks').start()

import {Application} from 'stimulus'
import {definitionsFromContext} from 'stimulus/webpack-helpers'

import Navbar from '../javascripts/bulmajs/plugins/navbar'
import Notification from '../javascripts/bulmajs/plugins/notification'

const application = Application.start()
const context = require.context('controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

require.context('../images', true)
