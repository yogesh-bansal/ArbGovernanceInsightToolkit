## Loading Libraries
library(shiny)
library(bslib)
library(networkD3)
library(DT)
library(shinycssloaders)
library(shinydashboard)

## UI
addResourcePath("images", "images")
ui <- fluidPage(theme = bs_theme(bootswatch = "sandstone"),
  br(),
  fluidRow(
    column(width = 3,tags$a(target = "_blank", href="https://thankarb.com/", tags$img(src = "images/AF_lockup_navy.png", height="80px")),align="left"),
    column(width = 6,h2("Governance Forum Insight Dashboard"),align="center"),
    column(width = 3,tags$a(target = "_blank", href="https://app.dework.xyz/datagrants-thankar", tags$img(src = "images/odcarb.png", height="100px")),align="right"),
  ),
  tabsetPanel(
    tabPanel("Likes Collusion Network",
      br(),
      sidebarLayout(
        sidebarPanel(width=3,
          p("Node Size is based on Number of Replies by the User while Node color shows the number of Topics created by the user."),
          p("Link Arrow shows which user has liked at least selected number of times on a user's posts."),
          hr(),
          sliderInput("like_cutoff", label = "Posts Liked", min = 5, max = 50, value = 15,step=5),
        ),
        mainPanel(width=9,
          column(width = 12,h5("Network showing users potentially colluding by Posting Comments/Replies on Topics created by certain Users."),align="center"),
          withSpinner(forceNetworkOutput("lcoll_network",height="700px"))
        )
      )
    ),
    tabPanel("Topic Reply Network",
      br(),
      sidebarLayout(
        sidebarPanel(width=3,
          p("Node Size is based on Number of Replies by the User while Node color shows the number of Topics created by the user."),
          p("Link Arrow shows which user has posted at least selected number of replies on a user's created topics."),
          hr(),
          sliderInput("reply_cutoff", label = "Replies Posted on Topic", min = 1, max = 10, value = 5,step=1),
        ),
        mainPanel(width=9,
          column(width = 12,h5("Network showing users potentially colluding by Posting Comments/Replies on Topics created by certain Users."),align="center"),
          withSpinner(forceNetworkOutput("rcoll_network",height="700px"))
        )
      )
    ),
    tabPanel("User Data",
      br(),
      fluidPage(
          downloadButton("downloadDataU", "Download"),
          withSpinner(dataTableOutput("UsersDF"))
      )
    ),
    tabPanel("Topic Data",
      br(),
      fluidPage(
          downloadButton("downloadDataT", "Download"),
          withSpinner(dataTableOutput("TopicsDF"))
      )
    ),
    tabPanel("Replies Data",
      br(),
      fluidPage(
          downloadButton("downloadDataR", "Download"),
          withSpinner(dataTableOutput("RepliesDF"))
      )
    ),
    tabPanel("Likes Data",
      br(),
      fluidPage(
          downloadButton("downloadDataL", "Download"),
          withSpinner(dataTableOutput("LikesDF"))
      )
    ),
    tabPanel("Badges Data",
      br(),
      fluidPage(
          downloadButton("downloadDataB", "Download"),
          withSpinner(dataTableOutput("BadgesDF"))
      )
    )
  )
)