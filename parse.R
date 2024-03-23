## Load Libraries
library(readr)
library(jsonlite)

## Load Datasets
udata <- read_csv("data/UsersDF.csv")	## User Table
udatal <- readRDS("tempdata/udatal.RDS")		## User Data
sdatal <- readRDS("tempdata/sdatal.RDS")		## Summary Data
bdatal <- readRDS("tempdata/bdatal.RDS")		## Badge Data
tdatal <- readRDS("tempdata/tdatal.RDS")		## Topics
adatal <- readRDS("tempdata/adatal.RDS")		## Actions Likes + Comments

########################################################################
## Topics DataFrame
########################################################################
parse_topic <- function(user,tdt)
{
	if(is.null(tdt)) return(data.frame())
	tdtt <- fromJSON(tdt)
	if(length(tdtt$topic_list$topics)==0) return(data.frame())
	data.frame(
				topicCreator = user,
				topicId = tdtt$topic_list$topics$id,
				topicTitle = tdtt$topic_list$topics$title,
				topicSlug = tdtt$topic_list$topics$slug,
				topicPostCount = tdtt$topic_list$topics$posts_count,
				topicReplyCount = tdtt$topic_list$topics$reply_count,
				topicViewCount = tdtt$topic_list$topics$views,
				topicLikeCount = tdtt$topic_list$topics$like_count,
				topicCategoryId = tdtt$topic_list$topics$category_id,
				topicTags = sapply(tdtt$topic_list$topics$tags,function(x) paste0(x,collapse=", ")),
				topicCreated = tdtt$topic_list$topics$created_at,
				topicLatest = tdtt$topic_list$topics$bumped_at,
				topicPinned = tdtt$topic_list$topics$pinned,
				topicVisible = tdtt$topic_list$topics$visible,
				topicClosed = tdtt$topic_list$topics$closed,
				topicVisible = tdtt$topic_list$topics$visible,
				topicArchieved = tdtt$topic_list$topics$archived,
				topicHasAcceptedAnswer = tdtt$topic_list$topics$has_accepted_answer
	)
}
TopicsDF <- do.call(rbind,mapply(parse_topic,udata$username,tdatal,SIMPLIFY=FALSE,USE.NAMES=FALSE))
write_csv(TopicsDF,"data/TopicsDF.csv")
########################################################################
########################################################################


########################################################################
## Replies DataFrame
########################################################################
parse_reply <- function(user,tdt)
{
	if(is.null(tdt)) return(data.frame())
	tdtt <- tdt[tdt$action_type==5,]
	data.frame(
				replyBy = tdtt$target_username,
				replyTopic = tdtt$topic_id,
				replyTopicSlug = tdtt$slug,
				replyPostNum = tdtt$post_number,
				replyToPostNum = tdtt$reply_to_post_number,
				replyAt = tdtt$created_at
	)
}
RepliesDF <- do.call(rbind,mapply(parse_reply,udata$username,adatal,SIMPLIFY=FALSE,USE.NAMES=FALSE))
write_csv(RepliesDF,"data/RepliesDF.csv")

parse_like <- function(user,tdt)
{
	if(is.null(tdt)) return(data.frame())
	tdtt <- tdt[tdt$action_type==1,]
	data.frame(
				likeBy = tdtt$target_username,
				likeTopic = tdtt$topic_id,
				likeTopicSlug = tdtt$slug,
				likePostNum = tdtt$post_number,
				likePostUser = tdtt$username,
				likeAt = tdtt$created_at
	)
}
LikesDF <- do.call(rbind,mapply(parse_like,udata$username,adatal,SIMPLIFY=FALSE,USE.NAMES=FALSE))
write_csv(LikesDF,"data/LikesDF.csv")
########################################################################
########################################################################

########################################################################
## Badges Dataframe
########################################################################
parse_badge <- function(user,tdt)
{
	if(is.null(tdt)) return(data.frame())
	tdtt <- fromJSON(tdt)
	if(length(tdtt$user_badges)==0) return(data.frame())
	data.frame(
				badgeHolder = user,
				badgeId = tdtt$user_badges$badge_id,
				badgeSlug = tdtt$badges$slug[match(tdtt$user_badges$badge_id,tdtt$badges$id)],
				badgeName = tdtt$badges$name[match(tdtt$user_badges$badge_id,tdtt$badges$id)],
				badgeDescription = tdtt$badges$description[match(tdtt$user_badges$badge_id,tdtt$badges$id)],
				badgeNumHolders = tdtt$badges$grant_count[match(tdtt$user_badges$badge_id,tdtt$badges$id)],
				badgeType = tdtt$badge_types$name[match(tdtt$badges$badge_type_id[match(tdtt$user_badges$badge_id,tdtt$badges$id)],tdtt$badge_types$id)]
	)
}
BadgesDF <- do.call(rbind,mapply(parse_badge,udata$username,bdatal,SIMPLIFY=FALSE,USE.NAMES=FALSE))
write_csv(BadgesDF,"data/BadgesDF.csv")
########################################################################
########################################################################