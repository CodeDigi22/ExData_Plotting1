#PLot4
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


#plot 4


# Ensure numeric and POSIXct types
data$Global_active_power <- as.numeric(data$Global_active_power)
data$Voltage <- as.numeric(data$Voltage)
data$Global_reactive_power <- as.numeric(data$Global_reactive_power)
data$Sub_metering_1 <- as.numeric(data$Sub_metering_1)
data$Sub_metering_2 <- as.numeric(data$Sub_metering_2)
data$Sub_metering_3 <- as.numeric(data$Sub_metering_3)
data$DateTime <- as.POSIXct(paste(data$Date, data$Time), format="%Y-%m-%d %H:%M:%S")

# Save all 4 plots in one PNG
png("plot4_combined.png", width=480, height=480)

# Set 2x2 layout
par(mfrow = c(2,2))

# 1. Global Active Power
plot(data$DateTime, data$Global_active_power, type="l", xlab="", ylab="Global Active Power", xaxt="n")
x_ticks <- seq(as.Date(min(data$DateTime)), as.Date(max(data$DateTime)), by="1 day")
axis(1, at=as.POSIXct(x_ticks), labels=format(x_ticks, "%a"))

# 2. Voltage
plot(data$DateTime, data$Voltage, type="l", xlab="datetime", ylab="Voltage", xaxt="n")
axis(1, at=as.POSIXct(x_ticks), labels=format(x_ticks, "%a"))

# 3. Energy Sub Metering
plot(data$DateTime, data$Sub_metering_1, type="l", xlab="", ylab="Energy sub metering", col="black", xaxt="n")
lines(data$DateTime, data$Sub_metering_2, col="red")
lines(data$DateTime, data$Sub_metering_3, col="blue")
axis(1, at=as.POSIXct(x_ticks), labels=format(x_ticks, "%a"))
legend("topright", legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
       col=c("black","red","blue"), lty=1, bty="n", cex=0.8)

# 4. Global Reactive Power
plot(data$DateTime, data$Global_reactive_power, type="l", xlab="datetime", ylab="Global Reactive Power", xaxt="n")
axis(1, at=as.POSIXct(x_ticks), labels=format(x_ticks, "%a"))

# Close the device
dev.off()

