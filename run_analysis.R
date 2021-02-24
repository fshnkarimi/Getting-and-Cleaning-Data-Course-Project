# Author : Afshin Karimi

# Install required packages
install.packages("data.table", dependencies=TRUE)
install.packages("reshape2", dependencies=TRUE)

# Load Packages
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
# get the Data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Get activity labels
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
# Get features                        
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
# Extracts the measurements on the mean and standard deviation for each measurement                  
mean_std_features <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[mean_std_features, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load train dataset
x_train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, mean_std_features, with = FALSE]
data.table::setnames(x_train, colnames(x_train), measurements)
y_train_activity <- fread(file.path(path, "UCI HAR Dataset/train/y_train.txt"), col.names = c("Activity"))
subject_train <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
x_train <- cbind(subject_train, y_train_activity, x_train)

# Load test dataset
X_test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, mean_std_features, with = FALSE]
data.table::setnames(X_test, colnames(X_test), measurements)
y_test_activity <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt"), col.names = c("Activity"))
subject_test <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
X_test <- cbind(subject_test, y_test_activity, X_test)

# Merges the training and the test sets to create one data set
merged_dataset <- rbind(x_train, X_test)

# Create a second, independent tidy data set with the average of each variable for each activity and each subject. 
merged_dataset[["Activity"]] <- factor(merged_dataset[, Activity], levels = activity_labels[["classLabels"]], labels = activity_labels[["activityName"]])
merged_dataset[["SubjectNum"]] <- as.factor(merged_dataset[, SubjectNum])
merged_dataset <- reshape2::melt(data = merged_dataset, id = c("SubjectNum", "Activity"))
merged_dataset <- reshape2::dcast(data = merged_dataset, SubjectNum + Activity ~ variable, fun.aggregate = mean)
data.table::fwrite(x = merged_dataset, file = "tidy_dataset.csv", quote = FALSE)

