##############################################
# This script will perform the following steps
#
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive variable names.
# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# For more information, see:
# https://github.com/dmarjenburgh/coursera-getdata-courseproject
##############################################

## Setup
if (!file.exists("features.txt"))
    stop("The required file features.txt was not found.",
         "Please ensure your working directory is set to the unzipped raw dataset folder.")
library(dplyr); library(tidyr)

## Constants
datagroups = c("test", "train")

## Load features
# Take only features measuring a mean or standard deviation.
features <- read.table("features.txt", col.names = c("ID", "Name")) %>%
    filter(grepl("-(mean|std)\\(\\)", Name)) %>%
    tbl_df

# Load subject data
subject <- lapply(datagroups, function (group) {
    filename <- paste(group, "/subject_", group, ".txt", sep = "")
    read.table(filename, col.names = "SubjectID") %>%
        mutate(Group = group)
}) %>% bind_rows %>% tbl_df

# Load activity
# 3. Use descriptive activity names to name the activities in the data set
act_labels <- read.table("activity_labels.txt", col.names = c("ID", "Activity"))
act <- lapply(datagroups, function (group) {
    filename <- paste(group, "/y_", group, ".txt", sep = "")
    read.table(filename, col.names = "Activity.ID")
}) %>% bind_rows %>% inner_join(act_labels, by = c("Activity.ID" = "ID"))

# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
measurements <- lapply(datagroups, function (group) {
    filename <- paste(group, "/X_", group, ".txt", sep = "")
    read.table(filename) %>% select(features$ID)
}) %>% bind_rows

# 4. Appropriately label the data set with descriptive variable names.
names(measurements) <- features$Name %>%
    sub("-mean\\(\\)", "Mean", .) %>% # remove ()
    sub("-std\\(\\)", "StdDev", .) %>%
    sub("^t", "Time", .) %>%
    sub("^f", "Frequency", .) %>%
    sub("BodyBody", "Body", .)

# Bind variables together
wide_data <- tbl_df(bind_cols(subject["SubjectID"], act["Activity"], measurements))
thin_data <- gather(wide_data, Feature, Value, -SubjectID, -Activity) %>%
    group_by(SubjectID, Activity, Feature)
summary <- summarise(thin_data, Average = mean(Value))

# Write output
write.csv(thin_data, "tidy.csv", row.names = FALSE)
write.csv(summary, "summary.csv", row.names = FALSE)
