# Pagination util
share.Paginator = class Paginator
  constructor: (nperpage) ->
    @currPage = 1
    @dep = new Deps.Dependency
    @npages = 0; @nelements = 0
    @rPerPage = nperpage or 10
  calibrate: (n) ->
    @nelements = n
    @npages = @nelements/@rPerPage
    @currPage = 1
    @dep.changed()
  page: (i) ->
    @dep.depend(); if i then @dep.changed() @currPage = i else @currPage
  next: ->
    if @currPage < @pages
      @currPage+=1; @dep.changed(); return yes
    else return no
  previous: ->
    if @currPage > 0
      @currPage-=1; @dep.changed(); return yes
    else return no
  slide: -> console.log "not implemented"
  perPage: (i) ->
    @dep.depend()
    if i then @dep.changed() @rPerPage = i else @rPerPage
  queryOptions: ->
    @dep.depend(); {limit: @perPage(), skip: @rPerPage*(@currPage-1)}
  pages: ->
    @dep.depend()
    list = []
    for p in [1..@npages+1]
      list.push { active: (if p is @currPage then 'active' else '')
      index: p }
    list
