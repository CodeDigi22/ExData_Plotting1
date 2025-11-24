
#Plot 1
#getwd()
#setwd
# create a data directory and download the zip file (if needed)
dir.create("data", showWarnings = FALSE)
fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
zipfile <- "data/household_power_consumption.zip"

if(!file.exists(zipfile)) {
  download.file(fileUrl, destfile = zipfile, mode = "wb")
}
# unzip (results in household_power_consumption.txt)
if(!file.exists("data/household_power_consumption.txt")) {
  unzip(zipfile, exdir = "data")
}
data_file <- "data/household_power_consumption.txt"



####
install.packages("sqldf")     # if not installed
library(sqldf)

# SQL to select only the two dates
sql <- "SELECT * FROM file WHERE Date IN ('1/2/2007','2/2/2007')"

# read.csv.sql does NOT accept na.strings directly, so we read normally and convert '?' to NA after
data <- read.csv.sql(data_file, sql = sql, sep = ";", header = TRUE, stringsAsFactors = FALSE, eol = "\n")

# Replace '?' with NA (optional if still present)
data[data == "?"] <- NA

# Convert columns to numeric (they may be character because of '?')
numeric_cols <- c("Global_active_power","Global_reactive_power","Voltage",
                  "Global_intensity","Sub_metering_1","Sub_metering_2","Sub_metering_3")
data[numeric_cols] <- lapply(data[numeric_cols], as.numeric)

# Convert Date and Time
data$Date <- as.Date(data$Date, format = "%d/%m/%Y")
data$DateTime <- as.POSIXct(paste(data$Date, data$Time), format = "%Y-%m-%d %H:%M:%S")

# Quick check
dim(data)        # should be 2880 rows x 10 columns
head(data)


#plot1

# Make sure Global_active_power is numeric
data$Global_active_power <- as.numeric(data$Global_active_power)

# Save histogram as PNG in a known location
png(filename = "plot1.png", width = 480, height = 480)

hist(data$Global_active_power,
     col = "red",
     main = "Global Active Power",
     xlab = "Global Active Power (kilowatts)")

dev.off()  # closes the device

