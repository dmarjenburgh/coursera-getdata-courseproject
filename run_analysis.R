## Setup

rm(list=ls()) # Clear the Global Environment
setwd("~/Coursera/DataScience/getdata/week3/courseProject/UCI HAR Dataset")
library(dplyr); library(tidyr)

## Load features
# Take features measuring a mean or standard deviation.
features <- read.csv("features.txt",
                     header = FALSE,
                     sep = "",
                     col.names = c("ID", "Name")) %>%
            filter(grepl("-(mean|std)\\(\\)", Name)) %>%
            tbl_df

# Load subject data
subject_test <- read.csv("test/subject_test.txt",
                         header = FALSE,
                         col.names = "SubjectID") %>%
                mutate(Group = factor("test"))
subject_train <- read.csv("train/subject_train.txt",
                          header = FALSE,
                          col.names = "SubjectID") %>%
                 mutate(Group = factor("train"))
subject <- rbind(subject_test, subject_train) %>% tbl_df

# Load activity
act_labels <- read.csv("activity_labels.txt",
                       header = F,
                       sep = "",
                       col.names = c("ID", "Activity"))
act_test <- read.csv("test/y_test.txt",
                     header = F,
                     col.names = "Activity.ID")
act_train <- read.csv("train/y_train.txt",
                     header = F,
                     col.names = "Activity.ID")
act <- inner_join(rbind(act_test, act_train),
                  act_labels,
                  by = c("Activity.ID" = "ID")) %>%
        tbl_df

# Load values
val_test <- read.csv("test/X_test.txt", header = FALSE, sep = "") %>%
            select(features$ID)
val_train <- read.csv("train/X_train.txt", header = FALSE, sep = "") %>%
             select(features$ID)
measurements <- rbind(val_test, val_train) %>% tbl_df
# Assign colNames. Remove the '()' for readability
names(measurements) <- sub("\\(\\)", "", features$Name)

# Bind variables together
wide_data <- bind_cols(subject["SubjectID"], act["Activity"], measurements) %>%
             tbl_df
thin_data <- gather(wide_data, Feature, Value, -SubjectID, -Activity) %>%
             group_by(SubjectID, Activity, Feature)
summary <- summarise(thin_data, Average = mean(Value))
