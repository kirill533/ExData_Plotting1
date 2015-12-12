# declare path to the file
dataFile <- "../household_power_consumption.txt"

# First calculate a rough estimate of how much memory the dataset  --------

# extimate size 
totalLines <- 2075259
# read first 100 rows
df <- read.csv(dataFile, header = TRUE, nrows = 10000, na.strings = "?", sep = ';')

# real size is 126.8 Mb
print(format(object.size(df)*totalLines/10000, units="Mb"))

# Loading the data --------------------------------------------------------

# install sqldf package used to read partially the csv file  
if (! "sqldf" %in% installed.packages()[,1]) {
  install.packages("sqldf")
}

# load sqldf package
library(sqldf)

# We will only be using data from the dates 2007-02-01 and 2007-02-02.
# One alternative is to read the data from just those dates rather than reading 
# in the entire dataset and subsetting to those dates.
df <- read.csv.sql(dataFile, 'SELECT * FROM file WHERE Date in("1/2/2007", "2/2/2007")', sep = ';')
# get rid of "closing unused connection" Warning
closeAllConnections()

#  dataset missing values are coded as ?
df[df == "?"] <- NA

# convert the Date and Time variables to Date/Time classes 
# in R using the strptime() and as.Date() functions
df$DateTime <- as.POSIXct(strptime(paste0(df$Date, " ",df$Time), format = '%d/%m/%Y %H:%M:%S'))

# Making Plots ------------------------------------------------------------

png('plot3.png', height = 480, width = 480)

r <- range(c(df$Sub_metering_1, df$Sub_metering_2, df$Sub_metering_3))
Sys.setlocale("LC_ALL","English")
plot(df$Sub_metering_1 ~ df$DateTime, ylim=r, type="l", ylab="Energy sub metering", xlab = "")
par(new = TRUE)
plot(df$Sub_metering_2 ~ df$DateTime, ylim=r, type="l", ylab = "", xlab = "", col="red")
par(new = TRUE)
plot(df$Sub_metering_3 ~ df$DateTime, ylim=r, type="l", ylab = "", xlab = "", col="blue")

legend("topright", legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col = c("black", "red", "blue"), lty=1)

dev.off()
