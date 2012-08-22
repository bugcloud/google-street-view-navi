_gSite = {}
_gSite.directionPathIndex = 0
_gSite.viewRotation = true

_gSite.mapInit = () ->
  _gSite.directionsDisplay = new google.maps.DirectionsRenderer()
  _gSite.directionsService = new google.maps.DirectionsService()
  _gSite.mapCanvas = document.getElementById("map-canvas")
  _gSite.mapPanoramaCanvas = document.getElementById("map-sv-canvas")
  _gSite.orgLatLng = new google.maps.LatLng(35.466487, 139.620795)
  _gSite.distLatLng = new google.maps.LatLng(35.293194, 139.57146)
  _gSite.gMapOptions =
    zoom: 10,
    center: _gSite.orgLatLng,
    mapTypeId: google.maps.MapTypeId.ROADMAP

  _gSite.gPanoramaOptions =
    position: _gSite.orgLatLng,
    pov: { heading: 0, pitch: 10, zoom: 0 }

  _gSite.map = new google.maps.Map(_gSite.mapCanvas, _gSite.gMapOptions)
  _gSite.orgPin = new google.maps.Marker
    position: _gSite.orgLatLng,
    draggable: true,
    animation: google.maps.Animation.DROP,
    title: 'Start Point',
    icon: 'img/start.png',
    map: _gSite.map
  _gSite.distPin = new google.maps.Marker
    position: _gSite.distLatLng,
    draggable: true,
    animation: google.maps.Animation.DROP,
    title: 'Distination Point',
    icon: 'img/finish.png',
    map: _gSite.map
  _gSite.directionsDisplay.setMap _gSite.map

  google.maps.event.addListener _gSite.orgPin, 'dragend', () ->
    _gSite.orgLatLng = _gSite.orgPin.getPosition()
    _gSite.gPanoramaOptions.position = _gSite.orgLatLng
  google.maps.event.addListener _gSite.distPin, 'dragend', () ->
    _gSite.distLatLng = _gSite.distPin.getPosition()

_gSite.renderNavigation = () ->
  _gSite.pin = new google.maps.Marker
    position: _gSite.orgLatLng,
    map: _gSite.map

  _gSite.directionRequest =
    origin: _gSite.orgLatLng.toUrlValue(),
    destination: _gSite.distLatLng.toUrlValue(),
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
          _gSite.map.setCenter pos
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
    _gSite.map.setCenter _gSite.orgLatLng
    callback.call(that_)
  , 700

$ ->
  _gSite.mapInit()
  $("#navigation-start").on 'click', () ->
    _gSite.hideMap _gSite.renderNavigation

  $("#map-sv-canvas").hover(
    () ->
      _gSite.viewRotation = false
    , () ->
      _gSite.viewRotation = true
  )
