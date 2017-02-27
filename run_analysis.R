library(dplyr)
setwd("UCI HAR Dataset")

##############################################################################################
#                        load features and activities information                            #
##############################################################################################
#read the list of the features
features <- tbl_df(read.table("features.txt"))
features$V2 <- gsub("\\()","",gsub("-","",features$V2))

#read the list of the activities
activity <- tbl_df(read.table("activity_labels.txt"))
colnames(activity) <- c("activityid","activity")

##############################################################################################
#                                      load train and test data                              #
##############################################################################################
#load train and test data
traindata <- data.frame(read.table("train/X_train.txt"))
testdata <- tbl_df(read.table("test/X_test.txt"))
alldata <- rbind(traindata, testdata)

#name the column of the df
colnames(alldata) <- as.vector(features$V2)

##############################################################################################
#                                      load Activities data                                  #
##############################################################################################
#load activities data for both "train and test" and add descriptive info to it
trainid <- data.frame(read.table("train/y_train.txt"))
testid <- tbl_df(read.table("test/y_test.txt"))
allactivity <- rbind(trainid, testid)
colnames(allactivity) <- c("activityid")

activityall <- right_join(activity,allactivity, by = "activityid")

##############################################################################################
#                                  load subject data                                         # 
##############################################################################################
#load the subject data for both "train and test"
subjecttrain <- tbl_df(read.table("train/subject_train.txt"))
subjecttest <- tbl_df(read.table("test/subject_test.txt"))
allsubject <- rbind(subjecttrain, subjecttest)
colnames(allsubject) <- "subject"

#Extracts only the measurements on the mean and standard deviation for each measurement 
alldata.col <- data.frame(alldata[, grepl("mean|std" ,names(alldata))])

#Create the tidy data set
tidydata <- cbind(allsubject,cbind(activityall,alldata.col))
tidydata <- transform(tidydata, subject = factor(subject))

##############################################################################################
#                       Calculate the mean for the variables                                 # 
##############################################################################################
#Independent tidy data set with the average of each variable for each subject and each activity.
alldatamean <- aggregate(tidydata[, 4:82],list(tidydata$subject, tidydata$activity), mean)
names(alldatamean)[1:2] <- c("subject","activity")
alldatamean <- arrange(alldatamean, subject)

##############################################################################################
#                                Extract the tidy data set                                   # 
##############################################################################################
write.table(alldatamean, file = "tidy.txt", sep = " ",quote = FALSE,
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = TRUE)
