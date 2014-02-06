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
#
#    PANEL
#
# -----------------------------------------------------------------------------
class Panel

  CONFIG = 
    default_picture : "main.jpg" # in the static/images folder

  constructor: (navigation) ->

    @navigation = navigation
    @ui  = $(".Panel")
    @uis =
      all_views: $(".Panel .view")
      views:
        intro          : $(".view.intro_main"                     , @ui)
        single_project : $(".view.single_project"                 , @ui)
        start_overview : $(".view.start_overview"                 , @ui)
        overview_intro : $(".view.overview_intro"                 , @ui)
        overview       : $(".view.overview"                       , @ui)
      navigation_btn :   $(".navigation-buttons"                  , @ui)
      prv_button     :   $(".prv_button"                          , @ui)
      nxt_button     :   $(".nxt_button"                          , @ui)
      tour_button    :   $(".tour_button"                         , @ui)
      overview_button:   $(".overview_button"                     , @ui)
      # single project (TOUR MODE)
      project:
        title      :     $(".single_project .title"               , @ui)
        location   :     $(".single_project .location"            , @ui)
        description:     $(".single_project .description .wrapper", @ui)
        img        :     $(".img_container"                       , @ui)
      # country infos (OVERVIEW_MODE)
      overview:
        location    :    $(".overview .location"                  , @ui)
        amount      :    $(".overview #tot_usd"                   , @ui)
        nb_projects :    $(".overview #tot_prj"                   , @ui)

    @chartWidget = new Chart()

    # Bind events
    $(window)           .resize                    @relayout
    $(document)         .on 'projectSelected' ,    @onProjectSelected
    $(document)         .on 'overviewSelected',    @onOverviewSelected
    $(document)         .on 'modeChanged'     ,    @onModeChanged
    $(document)         .on 'loading'         ,    @onLoadingChanged
    @uis.prv_button     .on 'click'           ,    @navigation.previousProject
    @uis.nxt_button     .on 'click'           ,    @navigation.nextProject
    @uis.tour_button    .on 'click'           , => @navigation.setMode(MODE_TOUR)
    @uis.overview_button.on 'click'           , => @navigation.setMode(MODE_OVERVIEW_INTRO)

    # resize
    @relayout()

  relayout: =>
    # usefull for the scrollbar: set the description height
    description    = $($(".Panel .description").get(@navigation.mode)) # select the current description
    navigation_btn = $(@uis.navigation_btn.get(@navigation.mode))
    description.css
      height : $(window).height() - description.offset().top - navigation_btn.outerHeight(true)

  changeIllustration:(img=CONFIG.default_picture) =>
      @uis.project.img.fadeOut -> 
        $(this)
          .css("background-image","url('static/images/#{img}')")
          .fadeIn()

  onProjectSelected: (e, project) =>
    if project?
      @uis.project.title       .html project.title
      @uis.project.location    .html project.recipient_oecd_name
      @uis.project.description .html(project.description)
      @uis.project.description.parent().scrollTop(0) # scroll to the top
      @changeIllustration(project.img)
      description = $($(".Panel .description").get(@navigation.mode)) # select the current description
        .perfectScrollbar()
    else
      @changeIllustration() #default illustration

  onOverviewSelected: (e, country) =>
    if country?
      details = @navigation.data.projects_details.get(country.Country)
      @uis.overview.location    .html country.Country
      @uis.overview.amount      .html abbreviateNumber(country.USD)
      @uis.overview.nb_projects .html details['total']
      @chartWidget.render(details)
    else
      @changeIllustration()  #default illustration

  onModeChanged: (e, mode) =>
    ### hide all the views, show the wanted one ###
    @uis.all_views.addClass "hidden"
    @uis.views.intro         .removeClass("hidden") if mode == MODE_INTRO
    @uis.views.single_project.removeClass("hidden") if mode == MODE_TOUR
    @uis.views.start_overview.removeClass("hidden") if mode == MODE_START_OVERVIEW
    @uis.views.overview_intro.removeClass("hidden") if mode == MODE_OVERVIEW_INTRO
    @uis.views.overview      .removeClass("hidden") if mode == MODE_OVERVIEW
    @relayout() # resize because the view has changed

# EOF
