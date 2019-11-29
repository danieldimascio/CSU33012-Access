install.packages("jsonlite")
install.packages("plotly")
install.packages("httpuv")
install.packages("httr")
install.packages("ggplot2")
install.packages("devtools")

library(jsonlite)
library(plotly)
library(httpuv)
library(httr)
library(ggplot2)
library(devtools)

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


##############


#R will show the number of followers and public repositories I have in my GitHub a/c.

#Preparing data for follower and repository info:                   // I have retroactively labelled all following 
#                                                                   // data with 'M' to differentiate from the second part of the assignment
MallData = GET("https://api.github.com/users/danieldimascio", gtoken)
MdataCont = content(MallData)
Mfollowers = GET("https://api.github.com/users/danieldimascio/followers", gtoken)
MfollowCont = content(Mfollowers)
Mrepository = GET("https://api.github.com/users/danieldimascio/repos", gtoken)
MrepoCont = content(Mrepository)

#Translate all into data frames:
MdataFrame = jsonlite::fromJSON(jsonlite::toJSON(MdataCont))
MfollowerFrame = jsonlite::fromJSON(jsonlite::toJSON(MfollowCont))
MrepoFrame = jsonlite::fromJSON(jsonlite::toJSON(MrepoCont))

#Information regarding the data:
MdataFrame$followers         #Num followers
MdataFrame$public_repos      #Num public repositories
MfollowerFrame$login         #login names of followers
Mlength(followerFrame$login) 
MrepoFrame$name              #Repo names
MrepoFrame$created_at        #Date repo created

##Using the repository of Carl Lerche, an active R developer who is frequently trending on GitHub. He has 1.3k followers and
##username: carllerche

#Like last time, I will prepare the data before running it:
allData = GET("https://api.github.com/users/carllerche", gtoken)
dataCont = content(allData)
followers = GET("https://api.github.com/users/carllerche/followers?per_page=100", gtoken)
followCont = content(followers)
repository = GET("https://api.github.com/users/carllerche/repos", gtoken)
repoCont = content(repository)

dataFrame = jsonlite::fromJSON(jsonlite::toJSON(dataCont))
followerFrame = jsonlite::fromJSON(jsonlite::toJSON(followCont))
repoFrame = jsonlite::fromJSON(jsonlite::toJSON(repoCont))
 
dataFrame$followers         #Num followers
dataFrame$public_repos      #Num public repositories
dataFrame$login             #login name

length(followerFrame$login)
repoFrame$name              #Repo names
repoFrame$created_at        #Date repo created

# List of usernames
followerFrame$login        
user_ids = c(followerFrame$login)

# Create empty set
users = c()
usersDB = data.frame(username = integer(), following = integer(), followers = integer(), repos = integer(), dateCreated = integer())

#Add users to list
for(i in 1:length(user_ids))
{
  followURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followReq = GET(followURL, gtoken)
  followCont = content(followReq)
  
  if(length(followCont) == 0)
  {
    next
  }
  
  followDFrame = jsonlite::fromJSON(jsonlite::toJSON(followCont))
  followLog = followDFrame$login
  
  #Loop through users
  for (j in 1:length(followLog))
  {
    if (is.element(followLog[j], users) == FALSE)
    {
      users[length(users) + 1] = followLog[j] #Adds user to list
      
      followURL2 = paste("https://api.github.com/users/", followLog[j], sep = "")
      following2 = GET(followURL2, gtoken)
      followCont2 = content(following2)
      followDFrame2 = jsonlite::fromJSON(jsonlite::toJSON(followCont2))
      
      
      followingNumber = followDFrame2$following #following
      followersNumber = followDFrame2$followers #followers
      reposNumber = followDFrame2$public_repos  #Repo num
      yearCreated = substr(followDFrame2$created_at, start = 1, stop = 4) #year joined

      usersDB[nrow(usersDB) + 1, ] = c(followLog[j], followingNumber, followersNumber, reposNumber, yearCreated)
    }
    next
  }
  if(length(users) > 100) #stop after 100 entries
  {
    break
  }
  next
}

#Link to plotly
Sys.setenv("plotly_username"="daniel.dimascio")
Sys.setenv("plotly_api_key"="VYQoMmwkI5SYBNS6yNoM")

#Below graphs the plot of Lerche's followers 10 most popular programming languages.
languages = c()

for (i in 1:length(users))
{
  reposURL = paste("https://api.github.com/users/", users[i], "/repos", sep = "")
  repos = GET(reposURL, gtoken)
  reposContent = content(repos)
  reposDF = jsonlite::fromJSON(jsonlite::toJSON(reposContent))
  reposNames = reposDF$name
  
  #Loop through all the repositories of an individual user
  for (j in 1: length(reposNames))
  {
   
    reposURL2 = paste("https://api.github.com/repos/", users[i], "/", reposNames[j], sep = "")
    repos2 = GET(reposURL2, gtoken)
    reposContent2 = content(repos2)
    reposDF2 = jsonlite::fromJSON(jsonlite::toJSON(reposContent2))
    language = reposDF2$language
    
    if (length(language) != 0 && language != "<NA>")
    {
      languages[length(languages)+1] = language
    }
    next
  }
  next
}

#Puts 10 most popular languages in table
allLanguages = sort(table(languages), increasing=TRUE)
top10Languages = allLanguages[(length(allLanguages)-9):length(allLanguages)]
languageDF = as.data.frame(top10Languages)

#PlotLang is a barchart.

plotLang = plot_ly(data = languageDF, x = languageDF$languages, y = languageDF$Freq, type = "bar")
plotLang

#Sends graph to plotly
api_create(plot3, filename = "10 Most Popular Languages")
#View on plotly for a better visualisation of the data: https://plot.ly/~daniel.dimascio/5/#/
