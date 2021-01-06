/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/webpacker and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('channels')

import {Application} from 'stimulus'
import {definitionsFromContext} from 'stimulus/webpack-helpers'

import Navbar from '../javascripts/bulmajs/plugins/navbar'
import Notification from '../javascripts/bulmajs/plugins/notification'

const application = Application.start()
const context = require.context('controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

require.context('../images', true)
