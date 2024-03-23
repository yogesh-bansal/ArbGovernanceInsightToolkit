## Loading Libraries
library(shiny)
library(networkD3)
library(DT)
library(readr)

########################################################################
## Load All data
########################################################################
UserD <- read_csv("data/UsersDF.csv",show_col_types = FALSE)
TopicD <- read_csv("data/TopicsDF.csv",show_col_types = FALSE)
RepliesD <- read_csv("data/RepliesDF.csv",show_col_types = FALSE)
LikesD <- read_csv("data/LikesDF.csv",show_col_types = FALSE)
BadgesD <- read_csv("data/BadgesDF.csv",show_col_types = FALSE)

## Like Matrix
all_usersL <- unique(c(LikesD$likeBy,LikesD$likePostUser))
na_to_zero <- function(x) ifelse(is.na(x),0,x)
likes_l <- list()
for(idx in 1:length(all_usersL))
{
	cuser <- all_usersL[idx]
	clikes <- LikesD$likePostUser[LikesD$likeBy==cuser]
	clikest <- table(clikes)
	likes_l[[idx]] <- as.numeric(na_to_zero(clikest[match(all_usersL,names(clikest))]))
	# message(idx)
}
likes_mat <- do.call(rbind,likes_l)
rownames(likes_mat) <- all_usersL
colnames(likes_mat) <- all_usersL

## Reply Matrix
all_usersR <- unique(c(TopicD$topicCreator[match(RepliesD$replyTopic,TopicD$topicId)],RepliesD$replyBy))
na_to_zero <- function(x) ifelse(is.na(x),0,x)
replies_l <- list()
for(idx in 1:length(all_usersR))
{
	cuser <- all_usersR[idx]
	creplies <- TopicD$topicCreator[match(RepliesD$replyTopic[RepliesD$replyBy==cuser],TopicD$topicId)]
	crepliest <- table(creplies)
	replies_l[[idx]] <- as.numeric(na_to_zero(crepliest[match(all_usersR,names(crepliest))]))
	# message(idx)
}
replies_mat <- do.call(rbind,replies_l)
rownames(replies_mat) <- all_usersR
colnames(replies_mat) <- all_usersR
########################################################################
########################################################################


########################################################################
## Server Code
########################################################################
function(input, output, session) {

	## Network Plot
    output$lcoll_network <- renderForceNetwork({
												like_links <- as.data.frame(cbind(which(likes_mat>input$like_cutoff,arr.ind=TRUE),value=1))
												if(nrow(like_links)==0) return(NULL)
												names(like_links) <- c("source","target","value")
												like_links$sourceName <- all_usersL[like_links$source]
												like_links$targetName <- all_usersL[like_links$target]
												cut_users <- unique(c(like_links$sourceName,like_links$targetName))
												like_links$source <- match(like_links$sourceName,cut_users)-1
												like_links$target <- match(like_links$targetName,cut_users)-1
												like_nodes <- data.frame(
																			name=cut_users,
																			group=c("No Topics Created","1 to 3 Topics Created","More than 3 Topics Created")[findInterval(UserD$topic_count[match(cut_users,UserD$username)],c(0,1,3))],
																			size=UserD$post_count[match(cut_users,UserD$username)]
																)
												my_color1 <- 'd3.scaleOrdinal() .domain(["No Topics Created", "1 to 3 Topics Created","More than 3 Topics Created"]) .range(["#9DCCED","#12AAFF","#213147"])'
												forceNetwork(
													Links = like_links,
													Nodes = like_nodes,
													Source = "source", 
													Target = "target",
													Value = "value", 
													NodeID = "name",
													Nodesize = "size",
													Group = "group",
													legend=TRUE,
													linkDistance = 100,
													colourScale=my_color1,
													opacity = 1,
													fontSize = 12,
													opacityNoHover = 1,
													bounded=TRUE,
													zoom = FALSE,
													arrows = TRUE
												)

                            })

    ## Network Plot
    output$rcoll_network <- renderForceNetwork({
												reply_links <- as.data.frame(cbind(which(replies_mat>input$reply_cutoff,arr.ind=TRUE),value=1))
												if(nrow(reply_links)==0) return(NULL)
												names(reply_links) <- c("source","target","value")
												reply_links$sourceName <- all_usersR[reply_links$source]
												reply_links$targetName <- all_usersR[reply_links$target]
												reply_links <- reply_links[reply_links$sourceName != reply_links$targetName,]
												cut_users <- unique(c(reply_links$sourceName,reply_links$targetName))
												reply_links$source <- match(reply_links$sourceName,cut_users)-1
												reply_links$target <- match(reply_links$targetName,cut_users)-1
												reply_nodes <- data.frame(
																			name=cut_users,
																			group=c("No Topics Created","1 to 3 Topics Created","More than 3 Topics Created")[findInterval(UserD$topic_count[match(cut_users,UserD$username)],c(0,1,3))],
																			size=UserD$post_count[match(cut_users,UserD$username)]
																)
												my_color2 <- 'd3.scaleOrdinal() .domain(["No Topics Created", "1 to 3 Topics Created","More than 3 Topics Created"]) .range(["#9DCCED","#12AAFF","#213147"])'
												forceNetwork(
													Links = reply_links,
													Nodes = reply_nodes,
													Source = "source", 
													Target = "target",
													Value = "value", 
													NodeID = "name",
													Nodesize = "size",
													Group = "group",
													legend=TRUE,
													linkDistance = 100,
													colourScale=my_color2,
													opacity = 1,
													fontSize = 12,
													opacityNoHover = 1,
													bounded=TRUE,
													zoom = FALSE,
													arrows = TRUE
												)

                            })

    ## User Data
    output$downloadDataU <- downloadHandler(
	    filename = function() {
	      "UsersDF.csv"
	    },
	    content = function(file) {
	      write_csv(UserD, file)
	    }
  	)
    output$UsersDF <- renderDataTable({datatable(UserD,escape = FALSE,rownames=FALSE,options = list(paging = TRUE,bInfo = FALSE,ordering=TRUE,searching=TRUE,autoWidth = TRUE,bLengthChange = FALSE,pageLength = 20))})

    ## Topic Data
    output$downloadDataT <- downloadHandler(
	    filename = function() {
	      "TopicsDF.csv"
	    },
	    content = function(file) {
	      write_csv(TopicD, file)
	    }
  	)
  	output$TopicsDF <- renderDataTable({datatable(TopicD,escape = FALSE,rownames=FALSE,options = list(paging = TRUE,bInfo = FALSE,ordering=TRUE,searching=TRUE,autoWidth = TRUE,bLengthChange = FALSE,pageLength = 20))})

  	## Replies Data
    output$downloadDataR <- downloadHandler(
	    filename = function() {
	      "RepliesDF.csv"
	    },
	    content = function(file) {
	      write_csv(RepliesD, file)
	    }
  	)
  	output$RepliesDF <- renderDataTable({datatable(RepliesD,escape = FALSE,rownames=FALSE,options = list(paging = TRUE,bInfo = FALSE,ordering=TRUE,searching=TRUE,autoWidth = TRUE,bLengthChange = FALSE,pageLength = 20))})

  	## Likes Data
    output$downloadDataL <- downloadHandler(
	    filename = function() {
	      "LikesDF.csv"
	    },
	    content = function(file) {
	      write_csv(LikesD, file)
	    }
  	)
  	output$LikesDF <- renderDataTable({datatable(LikesD,escape = FALSE,rownames=FALSE,options = list(paging = TRUE,bInfo = FALSE,ordering=TRUE,searching=TRUE,autoWidth = TRUE,bLengthChange = FALSE,pageLength = 20))})

  	## Badges Data
    output$downloadDataB <- downloadHandler(
	    filename = function() {
	      "BadgesDF.csv"
	    },
	    content = function(file) {
	      write_csv(BadgesD, file)
	    }
  	)
  	output$BadgesDF <- renderDataTable({datatable(BadgesD,escape = FALSE,rownames=FALSE,options = list(paging = TRUE,bInfo = FALSE,ordering=TRUE,searching=TRUE,autoWidth = TRUE,bLengthChange = FALSE,pageLength = 20))})
}