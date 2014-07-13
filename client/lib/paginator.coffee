# Pagination util
share.Paginator = class Paginator
  constructor: (nperpage) ->
    @currPage = 1
    @dep = new Deps.Dependency
    @npages = 0; @nelements = 0
    @rPerPage = nperpage or 10
  calibrate: (n) ->
    @npages = Math.ceil n/@rPerPage
    @currPage = 1 if @currPage > @npages
    if n isnt @nelements
      @nelements = n; @dep.changed()
  page: (i) ->
    @dep.depend(); if i isnt @currPage then @currPage = i; @dep.changed()
    @currPage
  next: ->
    if @currPage < @pages
      @currPage+=1; @dep.changed(); return yes
    else return no
  previous: ->
    if @currPage > 0
      @currPage-=1; @dep.changed(); return yes
    else return no
  slide: (n) -> console.log "Paginator::slide not implemented"
  perPage: (i) ->
    @dep.depend()
    if i then @dep.changed() @rPerPage = i else @rPerPage
  queryOptions: ->
    @dep.depend(); {limit: @perPage(), skip: @rPerPage*(@currPage-1)}
  show: -> @dep.depend(); @npages > 1
  pages: ->
    @dep.depend(); list = []
    for p in [1..@npages]
      if p is @currPage
        list.push { activePage: 'active', index: p }
      else list.push index: p
    list
