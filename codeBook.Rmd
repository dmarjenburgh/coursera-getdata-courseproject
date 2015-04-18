Getting and Cleaning Data - Course Project Codebook
===================================================

The raw data
-----------
The original raw data is obtained from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

For more information from the source, see: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The raw dataset contains normalised measurements of sensor signals from an
embedded accelerometer and gyroscope in a smartphone. Below is a short summary of
how the raw data ties together. For a more complete overview, please see the
documentation in the link above and in the raw dataset.

The `activity_labels.txt` contains IDs and names for the 6 recorded activities:

1. Walking
2. Walking upstairs
3. Walking downstairs
4. Sitting
5. Standing
5. Laying

The data is split into the groups `test` and `train`. The number of observations in each are:

Group  | Number of obs. | Number of subjects
-------|----------------|-------------------
`test` | 2947           | 9
`train`| 7352           | 21


### Linking data across files.

- `subject_<group>.txt` links the observation with the subjectID
- `y_test_<group>.txt` links the observation with the activityID

Measurements were taken in fixed-width sliding windows of 2.56s with a frequency
of 50Hz, giving $2.56*50 = 128$ readings/window. Each line in each of the files in
the `Inertial Signals` folder holds these 128 values. (These files are not used
directly in our analysis.)

`features-info.txt` explains the 33 attributes that have been measured. For each,
17 aggregate values are calculated, including the mean and std. This gives
$33*17 = 516$ features per row. The `X_<group>.txt` files contain each of the 516
features on every line. Which feature belongs to which column is listed in
`features.txt`.

Identifying the variables
-------------------------
Our output will be a [molten dataset](http://vita.had.co.nz/papers/tidy-data.pdf)
containing the following 4 variables:

1. `SubjectID` - The unique numeric identifier for the subject performing the activity.
                The range is from 1 to 30.
2. `Activity` - A factor variable describing the activity. These are the 6
                activities described in `activity_labels.txt`, see above.
3. `Feature` - A factor variables for each of the feature we want the value of.
               (e.g. tBodyAcc-mean-X). See futher description below.
4. `Value` - The actual numeric value of the measures feature.

There are 33 attributes in the raw dataset. We only take 2 of the 17 calculated
values: the mean and the standard deviation of each. This is gives 66 Features.
Therefore, our output dataset will have $(2947 + 7352)*66 = 679,734$ rows.

The `Feature` variable is taken from the raw dataset. The measurements of the
mean and standard deviation contain `-mean()` and `-std()` in their names. For
readability we have removed the parenthesis. Otherwise the name is left unchanged.
If a Feature begins with a `t`, it represents a measurement in the time-domain,
if it begins with an `f`, it represents a measurement in the frequency-domain.
The Feature column could have been separated out further into multiple columns
denoting the Domain (Time or Frequency) and Statistic (Mean or StdDev), but we
have not done so as it was not needed for our analysis.

Summarized dataset
------------------
From the tidy data created, we create a summary containing the average value of
each variable for each subject and activity. The number of rows in this summary
is `num_subjects * num_activities * num_features` rows, or 
$30 \times 6 \times 66 = 11880$ rows.
