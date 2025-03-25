#' Data source: 
#' https://open.toronto.ca/dataset/daily-shelter-overnight-service-occupancy-capacity/ 


library(opendatatoronto)
library(dplyr)


# ------------------------------------------------------------------------------
# Download data
# ------------------------------------------------------------------------------
resources <- list_package_resources("21c83b32-d5a8-4106-a54f-010dbe49f6f2")
relevant <- filter(resources, format == "CSV" )    



# ------------------------------------------------------------------------------
# Preview data
# ------------------------------------------------------------------------------

relevant$name

# Check how many observations each file has
for (i in 1:nrow(relevant))
{
  tmp <- filter(relevant, row_number()==i) %>% get_resource()
  cat("row ", i, " has ", dim(tmp)[1] , "obs\n")
}

# Preview files that don't have a year in their name
relevant %>% filter(row_number() == 1) %>% get_resource %>% tail
relevant %>% filter(row_number() == 6) %>% get_resource %>% tail

#' 2 files per year; the first version for each year seems to be a preview
#' Files without a year in the name are for 2025



# ------------------------------------------------------------------------------
# Merge data
# ------------------------------------------------------------------------------

# Drop preview files and omit 2025
relevant <- relevant[7:10,]
relevant[,1] <- c("2022", "2021", "2023", "2024")
relevant <- arrange(relevant, name)

# Extract tibbles
tbls <- list()

for (i in 1:nrow(relevant))
{
  tbls[[i]] <- filter(relevant, row_number()==i) %>% get_resource
}

# Merge and export tibbles
alldata <- bind_rows(tbls, .id="file_id")
saveRDS(alldata, "alloccupancy.rds")
