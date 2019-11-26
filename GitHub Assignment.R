install.packages("jsonlite")
install.packages("httpuv")
install.packages("httr")

library(jsonlite)
library(httpuv)
library(httr)

#choose application
oauth_endpoints("github") 
app <- oauth_app(appname = "dimascid_sweng_access", key = "db9027e212b8af6161cd", secret = "8978f1b2bbd97989eda89f675dd0f37ee4c47ac7")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), app) 

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 

# The code above was sourced from Michael Galarnyk's blog:
# https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

###

#R will show the number of followers and public repositories I have in my GitHub a/c.

#Preparing data for follower and repository info:
allData = GET("https://api.github.com/users/danieldimascio", gtoken)
dataCont = content(allData)
followers = GET("https://api.github.com/users/danieldimascio/followers", gtoken)
followCont = content(followers)
repository = GET("https://api.github.com/users/danieldimascio/repos", gtoken)
repoCont = content(repository)

#Translate into data frame and display follower & public repo info:
dataFrame = jsonlite::fromJSON(jsonlite::toJSON(dataCont))
dataFrame$followers
dataFrame$public_repos