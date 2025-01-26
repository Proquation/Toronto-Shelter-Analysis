# data merging script
# https://open.toronto.ca/dataset/daily-shelter-overnight-service-occupancy-capacity/

library(opendatatoronto)
library(dplyr)

resources <- list_package_resources("21c83b32-d5a8-4106-a54f-010dbe49f6f2")
relevant <- filter(resources, format == "CSV" )

# Check why there are 2 csv files per year
for (i in 1:nrow(relevant))
{
  tmp <- filter(relevant, row_number()==i) %>% get_resource()
  cat("row ", i, " has ", dim(tmp)[1] , "obs\n")
}
# The first file for each year is just a preview
# Files without year in name are for 2025

# Use only 2021-2024 data
relevant <- relevant[7:10,]
relevant[,1] <- c("2022", "2021", "2023", "2024")
relevant <- arrange(relevant, name)


#  Combine all tables in relevant
tbls <- list()

for (i in 1:nrow(relevant))
{
  tbls[[i]] <- filter(relevant, row_number()==i) %>% get_resource
}

alldata <- bind_rows(tbls, .id="file_id")

# Save data
saveRDS(alldata, "alloccupancy.rds")
