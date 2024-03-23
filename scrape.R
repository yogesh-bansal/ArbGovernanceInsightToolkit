library(httr)
library(jsonlite)
library(dplyr)
library(readr)

########################################################
## Get User List
########################################################
page <- 0
userdata <- data.frame()
while(TRUE)
{
	resp <- GET(paste0("https://forum.arbitrum.foundation/directory_items.json?order=likes_received&page=",page,"&period=all"))
	userdata <- unique(bind_rows(userdata,fromJSON(content(resp,as="text"))$directory_items))
	message(length(unique(userdata$id)))
	if(nrow(fromJSON(content(resp,as="text"))$directory_items)<50) break()
	page <- page+1
}
userdataout <- userdata[,1:9]
userdataout$username <- userdata$user$username
userdataout$name <- userdata$user$name
userdataout$userdatajson <- paste0("https://forum.arbitrum.foundation/u/",userdataout$username,".json")
userdataout$summaryjson <- paste0("https://forum.arbitrum.foundation/u/",userdataout$username,"/summary.json")
write_csv(userdataout,"data/UsersDF.csv")

########################################################
########################################################


########################################################
## Get user info Example
########################################################
library(httr)
library(jsonlite)
library(dplyr)
library(readr)
udata <- read_csv("data/UsersDF.csv")
udata$badgejson <- paste0("https://forum.arbitrum.foundation/user-badges/",udata$username,".json?grouped=true")
udata$topicjson <- paste0("https://forum.arbitrum.foundation/topics/created-by/",udata$username,".json")

udatal <- list()
sdatal <- list()
bdatal <- list()
tdatal <- list()
adatal <- list()

get_actions <- function(user)
{
	offset=0
	actionsdf <- data.frame()
	while(TRUE)
	{
		tactionsdf <- fromJSON(paste0("https://forum.arbitrum.foundation/user_actions.json?offset=",offset,"&username=",user,"&filter=5,1"))$user_actions
		actionsdf <- bind_rows(actionsdf,tactionsdf)
		if(length(tactionsdf)==0) break()
		offset <- offset+30
	}
	message(paste0("Actions Pulled ",nrow(actionsdf)))
	return(actionsdf)
}

for(idx in 1:nrow(udata))
{
	udatal[[idx]] <- readLines(udata$userdatajson[idx])
	sdatal[[idx]] <- readLines(udata$summaryjson[idx])
	bdatal[[idx]] <- readLines(udata$badgejson[idx])
	tdatal[[idx]] <- readLines(udata$topicjson[idx])
	adatal[[idx]] <- get_actions(udata$username[idx])
	message(idx)
	if((idx %% 100)==0)
	{
		saveRDS(udatal,"tempdata/udatal.RDS")
		saveRDS(sdatal,"tempdata/sdatal.RDS")
		saveRDS(bdatal,"tempdata/bdatal.RDS")
		saveRDS(tdatal,"tempdata/tdatal.RDS")
		saveRDS(adatal,"tempdata/adatal.RDS")
	}
}
########################################################
########################################################
