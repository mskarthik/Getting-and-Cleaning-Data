##Please install these packages before running the script
library(stringr)
library(data.table)
library(dplyr)

##First read in all the files and store values in data frame variables with same name. 
features<-read.table("features.txt")
activity_labels <- read.table("activity_labels.txt")

X_train<-read.table("train/X_train.txt")
y_train<-read.table("train/y_train.txt")
subject_train<-read.table("train/subject_train.txt")

X_test<-read.table("test/X_test.txt")
y_test<-read.table("test/y_test.txt")
subject_test<-read.table("test/subject_test.txt")

##Merge the data frames to create a larger "lego" block
##After cbind the first column is the subject and the second column is the activity
##Features start thrid column onwards
total_train <- cbind(subject_train,y_train,X_train)
total_test <- cbind(subject_test,y_test,X_test)
total.df <- rbind(total_train,total_test)

##Select features that end with "mean()" or "std()"
std_mean_features <- subset(features,str_detect(V2,fixed("mean()"))|
                                     str_detect(V2,fixed("std()")))

##Select first two columns containing Subject and Activity
##Select features with mean and standard deviation only.
selected_cols <- c(1,2,std_mean_features$V1+2)
refined.df <- total.df[,selected_cols]

##Replace column number with feature names
names(refined.df) <- c("Subject", "Activity", as.character(std_mean_features$V2))

##Use labels for the Activity instead of numbers
refined.df$Activity <- activity_labels$V2[refined.df$Activity]

##Create summary dataframe
refined.dt <- data.table(refined.df)
summary <- refined.dt %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

write.table(refined.dt,"Refined_data.txt",row.name=FALSE)
write.table(summary,"Summary.txt",row.name=FALSE)
