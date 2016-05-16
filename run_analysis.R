############################################################################################
# This script prepare a tidy data that can be used for later analysis.                     #
# Data can be download directly at:                                                        #
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip   #
# Download and unzip the zip file in your working directory                                #
# Library plyr and knitr must be installed                                                 #
# ref: rstudio-pubs-static.s3.amazonaws.com                                                #
############################################################################################

library(plyr)

# Reading the activity files
dataActivityTest  <- read.table("./UCI HAR Dataset/test/Y_test.txt" ,header = FALSE)
dataActivityTrain <- read.table("./UCI HAR Dataset/train/Y_train.txt",header = FALSE)

# Reading the subject files
dataSubjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE)
dataSubjectTest  <- read.table("UCI HAR Dataset/test/subject_test.txt",header = FALSE)

# Reading the features files
dataFeaturesTest  <- read.table("UCI HAR Dataset/test/X_test.txt" ,header = FALSE)
dataFeaturesTrain <- read.table("UCI HAR Dataset/train/X_train.txt",header = FALSE)

# 1- Merging the training and the test sets to create one data set.
# Merge per row
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
# Name the variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table("UCI HAR Dataset/features.txt",header=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
# Merge per column to create one dataset
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# 2- Extracting only the measurements on the mean and standard deviation for each measurement.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# 3- Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",header = FALSE)
Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))

# 4- Appropriately labels the data set with descriptive variable names.
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# 5- Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
# Creating tidydata text fil
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

