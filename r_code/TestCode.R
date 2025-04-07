# Load libraries
library(ggplot2)
library(tidyverse)
library(openalexR)
library(readxl)
library(writexl)

# Function to preemptively handle empty or NULL fields
handle_empty <- function(x, default = NA) {
  if (is.null(x) || length(x) == 0) {
    return(default)
  }
  # If the element is a list, collapse it into a comma-separated string or extract the first element
  if (is.list(x)) {
    return(paste(unlist(x), collapse = ", "))
  }
  # If it is not a list, return the element as is
  return(x)
}

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
apc_info <- purrr::map_dfr(springer_works, function(work) {
  if (!is.null(work$apc_list)) {
    tibble(
      id = work$id,
      apc_value = handle_empty(work$apc_list$value),
      apc_currency = handle_empty(work$apc_list$currency),
      apc_value_usd = handle_empty(work$apc_list$value_usd)
    )
  } else {
    tibble(
      id = work$id,
      apc_value = NA,
      apc_currency = NA,
      apc_value_usd = NA
    )
  }
})

# Combine the APC data frame with the main data frame
springer_df <- purrr::map_dfr(springer_works, function(work) {
  tibble(
    id = work$id,
    title = handle_empty(work$title),
    display_name = handle_empty(work$display_name),
    author = handle_empty(ifelse(length(work$authorships) > 0, work$authorships[[1]]$author$display_name, NA)),
    publication_date = handle_empty(work$publication_date),
    so = handle_empty(work$so),
    so_id = handle_empty(work$so_id),
    host_organization = handle_empty(work$host_organization),
    issn_l = handle_empty(work$issn_l),
    url = handle_empty(work$url),
    pdf_url = handle_empty(work$pdf_url),
    license = handle_empty(work$license),
    version = handle_empty(work$version),
    first_page = handle_empty(work$first_page),
    last_page = handle_empty(work$last_page),
    volume = handle_empty(work$volume),
    issue = handle_empty(work$issue),
    is_oa = handle_empty(work$is_oa),
    is_oa_anywhere = handle_empty(work$is_oa_anywhere),
    oa_status = handle_empty(work$oa_status),
    oa_url = handle_empty(work$oa_url),
    any_repository_has_fulltext = handle_empty(work$any_repository_has_fulltext),
    language = handle_empty(work$language),
    grants = handle_empty(work$grants),
    cited_by_count = handle_empty(work$cited_by_count),
    counts_by_year = handle_empty(work$counts_by_year),
    publication_year = handle_empty(work$publication_year),
    cited_by_api_url = handle_empty(work$cited_by_api_url),
    ids = handle_empty(work$ids),
    doi = handle_empty(work$doi),
    type = handle_empty(work$type),
    referenced_works = handle_empty(work$referenced_works),
    related_works = handle_empty(work$related_works),
    is_paratext = handle_empty(work$is_paratext),
    is_retracted = handle_empty(work$is_retracted),
    concepts = handle_empty(work$concepts),
    topics = handle_empty(work$topics)
  )
})

# Merge springer_df and apc_df based on the 'id' column
merged_df <- left_join(springer_df, apc_info, by = "id")

# Add the new column with 'Y' as all the values
merged_df$`Corresponding Y/N` <- "Y"

# Save the updated data to a new Excel file
write_xlsx(merged_df, "allapcinfo_springer_works.xlsx")
