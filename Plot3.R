#PLot3
#getwd()
#setwd()
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


#plot3



# Combine Date and Time into full timestamp
data$DateTime <- as.POSIXct(paste(data$Date, data$Time), format="%Y-%m-%d %H:%M:%S")

# Convert sub-metering variables to numeric
data$Sub_metering_1 <- as.numeric(data$Sub_metering_1)
data$Sub_metering_2 <- as.numeric(data$Sub_metering_2)
data$Sub_metering_3 <- as.numeric(data$Sub_metering_3)

# Save the plot
png("plot3.png", width=480, height=480)

# Plot Sub_metering_1
plot(data$DateTime, data$Sub_metering_1, 
     type="l", 
     xlab="", 
     ylab="Energy sub metering", 
     col="black", 
     xaxt="n")

# Add Sub_metering_2 and Sub_metering_3
lines(data$DateTime, data$Sub_metering_2, col="red")
lines(data$DateTime, data$Sub_metering_3, col="blue")

# Set x-axis ticks based on actual data range
start_day <- as.Date(min(data$DateTime))
end_day <- as.Date(max(data$DateTime))
x_ticks <- seq(start_day, end_day, by="1 day")
axis(1, at=as.POSIXct(x_ticks), labels=format(x_ticks, "%a"))

# Add legend
legend("topright", 
       legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       col=c("black", "red", "blue"), 
       lty=1)

dev.off()
