#read file in train dataset into R and check their dimensions 
#to figure out how to merge them together

library(dplyr)
X_train<- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train<- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train<- read.table("./UCI HAR Dataset/train/subject_train.txt")
dim(X_train)
dim(y_train)
dim(subject_train)

#read features and coerce it into character
features<- read.table("./UCI HAR Dataset/features.txt")
features[,2]<- as.character(features[,2])

#select columns you want
featureswant<- grep("mean\\(\\)|std\\(\\)", features[,2])
X_train<- X_train[, featureswant]
#name X_train_new column
Columnname<- features[featureswant, 2]
colnames(X_train)<- Columnname

#merge X_train, y_train, and subject_train together
#rename y_train and subject_train
new_train<- cbind(X_train, y_train, subject_train)
names(new_train)[67]<- "activity"
names(new_train)[68]<- "subject"

#do the same thing to test dataset
#read the X_test, y_test and subject_test
X_test<- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test<- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test<- read.table("./UCI HAR Dataset/test/subject_test.txt")
dim(X_test)
dim(y_test)
dim(subject_test)

#selcet columns we want in X_test
X_test<- X_test[, featureswant]

#name X_train_new column
colnames(X_test)<- Columnname

#merge X_test, y_test, and subject_test together
#rename y_test and subject_test
new_test<- cbind(X_test, y_test, subject_test)
names(new_test)[67]<- "activity"
names(new_test)[68]<- "subject"

#merge new_train and new_test
newdata<- rbind(new_train, new_test)

activity_labels<- read.table("././UCI HAR Dataset/activity_labels.txt")
newdata<- mutate(newdata, activity= activity_labels[activity,2])

#rename newdata so that we can perform calculation
names(newdata)<- gsub("-","_", names(newdata))
names(newdata)<- gsub("\\(\\)", "",names(newdata))

#calculate means of each measurements by activity and subject
#make newdata from a wide data into a long data
library(reshape2)
newdatamelt<- melt(newdata, id= c("subject", "activity"))
names(newdatamelt) <- c("Subject","Activity","Measurement","Value")
#calculate means
newdatamean<- aggregate(newdatamelt$Value, 
              list(newdatamelt$Subject, newdatamelt$Activity, newdatamelt$Measurement), mean)
names(newdatamean)<- c("Subject", "Activity", "Measurement", "mean")

write.table(newdatamean, file= "tidydataset.txt", row.names= F)


