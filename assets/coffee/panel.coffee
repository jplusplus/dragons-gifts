# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 16-Jan-2014
# Last mod : 04-Feb-2014
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#
#    PANEL
#
# -----------------------------------------------------------------------------
class Panel

  constructor: (navigation) ->

    @navigation = navigation

    @uis =
      views          : $(".Panel .view")
      intro          : $(".Panel .view.intro_main")
      single_project : $(".Panel .view.single_project")
      start_overview : $(".Panel .view.start_overview")
      overview       : $(".Panel .view.overview")
      navigation_btn : $(".Panel .navigation-buttons")
      prv_button     : $(".Panel .prv_button")
      nxt_button     : $(".Panel .nxt_button")
      tour_button    : $(".Panel .tour_button")
      overview_button: $(".Panel .overview_button")
      title          : $(".Panel .single_project .title")
      location       : $(".Panel .single_project .location")
      description    : $(".Panel .single_project .description")

    # Bind events
    $(window)           .resize                   @relayout
    $(document)         .on 'projectSelected',    @onProjectSelected
    $(document)         .on 'modeChanged'    ,    @onModeChanged
    @uis.prv_button     .on 'click'          ,    @navigation.previousProject
    @uis.nxt_button     .on 'click'          ,    @navigation.nextProject
    @uis.tour_button    .on 'click'          , => @navigation.setMode(MODE_TOUR)
    @uis.overview_button.on 'click'          , => @navigation.setMode(MODE_OVERVIEW)

    # resize
    @relayout()

  relayout: =>
    # usefull for the scrollbar:
    # set the description height to use the overflow: auto style
    description    = $($(".Panel .description").get(@navigation.mode)) # select the current description
    navigation_btn = $(@uis.navigation_btn.get(@navigation.mode))
    description.css
      height : $(window).height() - description.offset().top - navigation_btn.outerHeight(true)

  onProjectSelected: (e, project) =>
    if project?
      @uis.title       .html project.title
      @uis.location    .html project.recipient_condensed
      @uis.description .html project.description

  onModeChanged: (e, mode) =>
    @uis.intro         .toggleClass("hidden", mode != MODE_INTRO)
    @uis.single_project.toggleClass("hidden", mode != MODE_TOUR)
    @uis.start_overview.toggleClass("hidden", mode != MODE_START_OVERVIEW)
    @uis.overview      .toggleClass("hidden", mode != MODE_OVERVIEW)
    @relayout() # resize because the view has changed

# EOF