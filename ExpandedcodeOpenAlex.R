# Install necessary packages
install.packages("ggplot2")
install.packages("tidyverse")
install.packages("openalexR")
install.packages("writexl")
install.packages("readxl")

# Load libraries
library(ggplot2)
library(tidyverse)
library(openalexR)
library(readxl)
library(writexl)

# OpenAlex Springer Call
options(openalexR.mailto = "coral.markan@mail.utoronto.ca")
springer_works <- oa_fetch(
  entity = "works", 
  locations.source.publisher_lineage = "https://openalex.org/P4310319965", 
  from_publication_date = "2019-01-01",
  to_publication_date = "2024-12-31",
  corresponding_institution_ids = "https://openalex.org/I185261750",
  output = "list"
)

# Check if any records were found
if (length(springer_works) == 0) {
  stop("No records found from the API")
}

# Extract APC information with a safety check for missing data
apc_info <- lapply(springer_works, function(work) {
  if (!is.null(work$apc_list)) {
    c(
      apc_value = work$apc_list$value,
      apc_currency = work$apc_list$currency,
      apc_value_usd = work$apc_list$value_usd
    )
  } else {
    c(apc_value = NA, apc_currency = NA, apc_value_usd = NA)
  }
})

# Convert the list to a data frame
apc_df <- do.call(rbind, apc_info)

# Combine the APC data frame with the main data frame
springer_df <- data.frame(
  id = sapply(springer_works, function(work) work$id),
  title = sapply(springer_works, function(work) work$title),
  display_name = sapply(springer_works, function(work) work$display_name),
  author = sapply(springer_works, function(work) work$authorships[[1]]$author$display_name),
  publication_date = sapply(springer_works, function(work) work$publication_date),
  so = sapply(springer_works, function(work) work$so),
  so_id = sapply(springer_works, function(work) work$so_id),
  host_organization = sapply(springer_works, function(work) work$host_organization),
  issn_l = sapply(springer_works, function(work) work$issn_l),
  url = sapply(springer_works, function(work) work$url),
  pdf_url = sapply(springer_works, function(work) work$pdf_url),
  license = sapply(springer_works, function(work) work$license),
  version = sapply(springer_works, function(work) work$version),
  first_page = sapply(springer_works, function(work) work$first_page),
  last_page = sapply(springer_works, function(work) work$last_page),
  volume = sapply(springer_works, function(work) work$volume),
  issue = sapply(springer_works, function(work) work$issue),
  is_oa = sapply(springer_works, function(work) work$is_oa),
  is_oa_anywhere = sapply(springer_works, function(work) work$is_oa_anywhere),
  oa_status = sapply(springer_works, function(work) work$oa_status),
  oa_url = sapply(springer_works, function(work) work$oa_url),
  any_repository_has_fulltext = sapply(springer_works, function(work) work$any_repository_has_fulltext),
  language = sapply(springer_works, function(work) work$language),
  grants = sapply(springer_works, function(work) work$grants),
  cited_by_count = sapply(springer_works, function(work) work$cited_by_count),
  counts_by_year = sapply(springer_works, function(work) work$counts_by_year),
  publication_year = sapply(springer_works, function(work) work$publication_year),
  cited_by_api_url = sapply(springer_works, function(work) work$cited_by_api_url),
  ids = sapply(springer_works, function(work) work$ids),
  doi = sapply(springer_works, function(work) work$doi),
  type = sapply(springer_works, function(work) work$type),
  referenced_works = sapply(springer_works, function(work) work$referenced_works),
  related_works = sapply(springer_works, function(work) work$related_works),
  is_paratext = sapply(springer_works, function(work) work$is_paratext),
  is_retracted = sapply(springer_works, function(work) work$is_retracted),
  concepts = sapply(springer_works, function(work) work$concepts),
  topics = sapply(springer_works, function(work) work$topics),
  apc_value = apc_df[, "apc_value"],
  apc_currency = apc_df[, "apc_currency"],
  apc_value_usd = apc_df[, "apc_value_usd"]
)

# Add the new column with 'Y' as all the values
springer_df$`Corresponding Y/N` <- "Y"

# Save the updated data to a new Excel file
write_xlsx(springer_df, "allapcinfo_springer_works.xlsx")
