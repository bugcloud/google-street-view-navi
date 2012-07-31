_gSite = {}
_gSite.directionPathIndex = 0
_gSite.viewRotation = true

_gSite.mapInit = () ->
  _gSite.directionsDisplay = new google.maps.DirectionsRenderer()
  _gSite.directionsService = new google.maps.DirectionsService()
  _gSite.mapCanvas = document.getElementById("map-canvas")
  _gSite.mapPanoramaCanvas = document.getElementById("map-sv-canvas")
  _gSite.latLng = new google.maps.LatLng(35.466487, 139.620795)
  _gSite.gMapOptions =
    zoom: 15,
    center: _gSite.latLng,
    mapTypeId: google.maps.MapTypeId.ROADMAP

  _gSite.gPanoramaOptions =
    position: _gSite.latLng,
    pov: { heading: 0, pitch: 10, zoom: 0 }

  _gSite.map = new google.maps.Map(_gSite.mapCanvas, _gSite.gMapOptions)
  _gSite.pin = new google.maps.Marker
    position: _gSite.latLng,
    map: _gSite.map
  _gSite.directionsDisplay.setMap _gSite.map

_gSite.renderNavigation = () ->
  _gSite.directionRequest =
    origin: _gSite.latLng.toUrlValue(),
    destination: "35.293194,139.57146",
    travelMode: google.maps.TravelMode.DRIVING
  _gSite.directionsService.route _gSite.directionRequest, (result, status) ->
    _gSite.directionsDisplay.setDirections(result) if status is google.maps.DirectionsStatus.OK

  _gSite.panorama = new google.maps.StreetViewPanorama(_gSite.mapPanoramaCanvas, _gSite.gPanoramaOptions)

  _gSite.updatePanorama = () ->
    if _gSite.viewRotation
      h = _gSite.panorama.pov.heading
      h += 0.1
      h = 0 if (h >= 360)
      p =
        heading: h,
        pitch: _gSite.panorama.pov.pitch,
        zoom: _gSite.panorama.pov.zoom
      _gSite.panorama.setPov p

    if _gSite.directionsDisplay.directions
      routes = _gSite.directionsDisplay.directions.routes
      if routes.length > 0
        currentPath = routes[0].overview_path[_gSite.directionPathIndex/100]
        if currentPath and _gSite.directionPathIndex % 10 is 0 or _gSite.directionPathIndex/100 is routes[0].overview_path.length - 1
          poses = currentPath.toUrlValue().split(",")
          pos = new google.maps.LatLng(poses[0] * 1, poses[1] * 1)
          _gSite.panorama.setPosition pos
          _gSite.pin.setPosition pos
        _gSite.directionPathIndex += 1
    requestAnimationFrame _gSite.updatePanorama

  _gSite.updatePanorama()

_gSite.hideMap = (callback) ->
  that_ = this
  $("#map-canvas").css('opacity', .7).removeClass 'overview'
  setTimeout () ->
    google.maps.event.trigger(_gSite.map, 'resize')
    _gSite.map.setZoom 15
    _gSite.map.setCenter _gSite.latLng
    callback.call(that_)
  , 700

$ ->
  _gSite.mapInit()
  setTimeout () ->
    _gSite.hideMap _gSite.renderNavigation
  , 3000
  $("#map-sv-canvas").hover(
    () ->
      _gSite.viewRotation = false
    , () ->
      _gSite.viewRotation = true
  )
