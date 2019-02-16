/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/webpacker and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker')

import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'
import * as ActiveStorage from 'activestorage'

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import {Application} from 'stimulus'
import {definitionsFromContext} from 'stimulus/webpack-helpers'

import Navbar from '../javascripts/bulmajs/plugins/navbar'
import Notification from '../javascripts/bulmajs/plugins/notification'
//import '../javascripts/bulma/main'

const application = Application.start()
const context = require.context('controllers', true, /\.js$/)
application.load(definitionsFromContext(context))
