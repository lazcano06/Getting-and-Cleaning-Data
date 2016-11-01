## Creates Files if it doesn't exist
#Download file from url and unzip it 
    if(!file.exists("./GCDdata")){dir.create("./GCDdata")}
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl,destfile="./GCDdata/Dataset.zip")
    unzip(zipfile="./GCDdata/Dataset.zip",exdir="./GCDdata")

## Load tables to working enviroment
## Name Columns to combine/merge tables
    x_train <- read.table("./GCDdata/UCI HAR dataset/train/X_train.txt")
    y_train <- read.table("./GCDdata/UCI HAR dataset/train/y_train.txt")
    subject_train <- read.table("./GCDdata/UCI HAR dataset/train/subject_train.txt")
    
    x_test <- read.table("./GCDdata/UCI HAR dataset/test/X_test.txt")
    y_test <- read.table("./GCDdata/UCI HAR dataset/test/y_test.txt")
    subject_test <- read.table("./GCDdata/UCI HAR dataset/test/subject_test.txt")
    
    features <- read.table('./GCDdata/UCI HAR dataset/features.txt')
    
    act_labels = read.table('./GCDdata/UCI HAR dataset/activity_labels.txt')
    
    colnames(x_train) <- features[,2] 
    colnames(y_train) <-"activityId"
    colnames(subject_train) <- "subjectId"
    
    colnames(x_test) <- features[,2] 
    colnames(y_test) <- "activityId"
    colnames(subject_test) <- "subjectId"
    
    colnames(act_labels) <- c('activityId','activityType')

## Combine/Merge train and test tables into one single table (All_data)
    train_full <- cbind(y_train, subject_train, x_train)
    test_full <- cbind(y_test, subject_test, x_test)
    All_data <- rbind(train_full, test_full)

## Create subset of columns that we need.
## Use subset to filter the columns in our data set 
    data_names <- colnames(All_data)
    subset_col <- (grepl("activityId" , data_names) | 
                          grepl("subjectId" , data_names) | 
                          grepl("mean.." , data_names) | 
                          grepl("std.." , data_names)
    )
    
    All_data_subset <- All_data[ ,subset_col == TRUE]

## Merge data set with activity labels to get activity names
    All_data_subset <- merge(All_data_subset, act_labels,
                            by='activityId',
                            all.x=TRUE)

## Apply order to columns
    All_data_subset <- All_data_subset[,c(82,(1:81))]

## Rename data set labels with descriptive variables names
    names(All_data_subset)<- gsub("^t","time", names(All_data_subset))
    names(All_data_subset)<- gsub("^f","Frequency", names(All_data_subset))
    names(All_data_subset)<- gsub("Acc","Accelerometer", names(All_data_subset))
    names(All_data_subset)<- gsub("Gyro","Gyrosscope", names(All_data_subset))
    names(All_data_subset)<- gsub("Mag","Magnitude", names(All_data_subset))
    names(All_data_subset)<- gsub("BodyBody","Body", names(All_data_subset))

## Independent tidy data set with the average of each variable for 
## each activity and each subject.
## Write txt from 2nd tidy data set
    Cleaning_project <- aggregate(. ~subjectId + activityType, All_data_subset, mean)
    
    write.table(Cleaning_project, "Cleaning_project.txt", row.name=FALSE)
