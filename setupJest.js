import $ from 'jquery'
import * as L from 'leaflet'

// make jQuery globally available in tests as both "$" and "jQuery"
global.jQuery = $
global.$ = global.jQuery

// make leaflet globally available in tests as "L"
global.L = L
