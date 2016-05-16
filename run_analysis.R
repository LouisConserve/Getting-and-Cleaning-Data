############################################################################################
# This script prepare a tidy data that can be used for later analysis.                     #
# data can be download directly at:                                                        #
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20dataset.zip   #
# Download and unzip the zip file in your working directory                                #
# Library plyr and knitr must be installed                                                 #
# ref: rstudio-pubs-static.s3.amazonaws.com                                                #
############################################################################################

library(plyr)

# Reading the activity files
activity_test  <- read.table("./UCI HAR dataset/test/Y_test.txt" ,header = FALSE)
activity_train <- read.table("./UCI HAR dataset/train/Y_train.txt",header = FALSE)

# Reading the subject files
subject_train <- read.table("./UCI HAR dataset/train/subject_train.txt",header = FALSE)
subject_test  <- read.table("UCI HAR dataset/test/subject_test.txt",header = FALSE)

# Reading the features files
features_test <- read.table("UCI HAR dataset/test/X_test.txt" ,header = FALSE)
features_train <- read.table("UCI HAR dataset/train/X_train.txt",header = FALSE)

# 1- Merging the training and the test sets to create one data set.
# Merge per row
data_subject <- rbind(subject_train, subject_test)
data_activity<- rbind(activity_train, activity_test)
data_features<- rbind(features_train, features_test)
# Name the variables
names(data_subject)<-c("subject")
names(data_activity)<- c("activity")
features_names <- read.table("UCI HAR dataset/features.txt",header=FALSE)
names(data_features)<- features_names$V2
# Merge per column to create one dataset
merged_data <- cbind(data_subject, data_activity)
data <- cbind(data_features, merged_data)

# 2- Extracting only the measurements on the mean and standard deviation for each measurement.
sub_features<-features_names$V2[grep("mean\\(\\)|std\\(\\)", features_names$V2)]
select_names<-c(as.character(sub_features), "subject", "activity" )
data<-subset(data,select=select_names)

# 3- Uses descriptive activity names to name the activities in the data set
activity_names <- read.table("UCI HAR dataset/activity_labels.txt",header = FALSE)
data$activity<-factor(data$activity);
data$activity<- factor(data$activity,labels=as.character(activity_names$V2))

# 4- Appropriately labels the data set with descriptive variable names.
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

# 5- Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_data<-aggregate(. ~subject + activity, data, mean)
tidy_data<-tidy_data[order(tidy_data$subject,tidy_data$activity),]
# Creating tidydata text fil
write.table(tidy_data, file = "tidydata.txt",row.name=FALSE)

