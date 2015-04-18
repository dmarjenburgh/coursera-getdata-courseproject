library(dplyr); library(tidyr)
################################################################################
# This script will perform the following steps
#
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the means and standard deviations of each measured attribute.
# 3. Use descriptive activity names to name the activities in the data set
# 4. Label the data set with descriptive variable names.
# 5. Create a second, independent tidy data set with the average of each variable
#    for each activity and each subject.
#
# For more information, see:
# https://github.com/dmarjenburgh/coursera-getdata-courseproject
################################################################################

## Setup
if (!file.exists("features.txt"))
    stop("The required file features.txt was not found.",
         "Please ensure your working directory is set to the unzipped raw dataset folder.")

## Constants
datagroups <- c("test", "train")

## Load features
# Take only features measuring a mean or standard deviation.
features <- read.table("features.txt", col.names = c("ID", "Name")) %>%
    filter(grepl("-(mean|std)\\(\\)", Name)) %>% tbl_df

## Load subjects
subject <- lapply(datagroups, function (group) {
    filename <- paste0(group, "/subject_", group, ".txt")
    filename %>% read.table(col.names = "SubjectID") %>% mutate(Group = group)
}) %>% bind_rows %>% tbl_df

## Load activities
# 3. Use descriptive activity names to name the activities in the data set
act_labels <- read.table("activity_labels.txt", col.names = c("ID", "Activity"))
act <- lapply(datagroups, function (group) {
    filename <- paste0(group, "/y_", group, ".txt")
    filename %>% read.table(col.names = "Activity.ID")
}) %>% bind_rows %>% inner_join(act_labels, by = c("Activity.ID" = "ID"))

## Load measurements
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
measurements <- lapply(datagroups, function (group) {
    filename <- paste0(group, "/X_", group, ".txt")
    filename %>% read.table %>% select(features$ID)
}) %>% bind_rows

# 4. Appropriately label the data set with descriptive variable names.
names(measurements) <- features$Name %>%
    sub("-mean\\(\\)", "Mean", .)    %>% # rename -mean() to Mean
    sub("-std\\(\\)", "StdDev", .)   %>% # rename -std() to StdDev
    sub("^t", "Time", .)             %>% # replace starting t with Time
    sub("^f", "Frequency", .)        %>% # replace starting f with Frequency
    sub("BodyBody", "Body", .)           # replace BodyBody with Body

# Bind variables together
wide_data <- tbl_df(bind_cols(subject["SubjectID"], act["Activity"], measurements))
thin_data <- gather(wide_data, Feature, Value, -SubjectID, -Activity)

# 5. Create a second, independent tidy data set with the average of each variable
#    for each activity and each subject.
summary <- thin_data %>%
    group_by(SubjectID, Activity, Feature) %>%
    summarise(Average = mean(Value))

# Write output
write.table(thin_data, "tidy.txt", row.names = FALSE)
write.table(summary, "summary.txt", row.names = FALSE)
