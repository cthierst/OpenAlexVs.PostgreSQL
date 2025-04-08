install.packages("tidyverse")
install.packages("openalexR")
install.packages("writexl")

library(tidyverse)
library(openalexR)
library(writexl)

options(openalexR.mailto = "coral.markan@mail.utoronto.ca")


springer_works <- oa_fetch(
  entity = "works", 
  locations.source.publisher_lineage = "https://openalex.org/P4310319965", 
  from_publication_date = "2019-01-01",
  to_publication_date = "2024-12-31",
  corresponding_institution_ids = "https://openalex.org/I185261750",
  output = "dataframe"
)

# Check if any records were found
if (nrow(springer_works) == 0) {
  stop("No records found from the API")
}

cat("Found", nrow(springer_works), "publications\n")

# Print column names to understand the dataset structure
cat("Available columns in the dataset:\n")
print(colnames(springer_works))

# Create a function to safely extract values from columns that might be lists
safe_extract_column <- function(df, col_name, default = NA) {
  if (!col_name %in% colnames(df)) {
    return(rep(default, nrow(df)))
  }
  
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    val <- df[[col_name]][i]
    if (is.list(val) && length(val) > 0) {
      if (is.character(val[[1]])) {
        result[i] <- paste(unlist(val), collapse = "; ")
      } else {
        result[i] <- toString(val)
      }
    } else {
      result[i] <- if(is.null(val) || length(val) == 0) default else as.character(val)
    }
  }
  return(result)
}

# Extract first author name from authorships column
extract_first_author <- function(df) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    auth <- df$authorships[i]
    if (is.list(auth) && length(auth) > 0 && is.list(auth[[1]]) && 
        "author" %in% names(auth[[1]]) && is.list(auth[[1]]$author) && 
        "display_name" %in% names(auth[[1]]$author)) {
      result[i] <- auth[[1]]$author$display_name
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Extract all authors from authorships column
extract_all_authors <- function(df) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    auth <- df$authorships[i]
    if (is.list(auth) && length(auth) > 0) {
      # Extract all author names
      author_names <- sapply(auth, function(a) {
        if (is.list(a) && "author" %in% names(a) && 
            is.list(a$author) && "display_name" %in% names(a$author)) {
          return(a$author$display_name)
        } else {
          return(NA)
        }
      })
      result[i] <- paste(author_names[!is.na(author_names)], collapse = "; ")
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Extract corresponding authors from authorships column
extract_corresponding_authors <- function(df) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    auth <- df$authorships[i]
    if (is.list(auth) && length(auth) > 0) {
      # Extract corresponding author names
      corresponding_authors <- sapply(auth, function(a) {
        if (is.list(a) && "author" %in% names(a) && 
            is.list(a$author) && "display_name" %in% names(a$author) &&
            !is.null(a$is_corresponding) && a$is_corresponding == TRUE) {
          return(a$author$display_name)
        } else {
          return(NA)
        }
      })
      valid_authors <- corresponding_authors[!is.na(corresponding_authors)]
      result[i] <- if(length(valid_authors) > 0) paste(valid_authors, collapse = "; ") else NA
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Extract APC information
extract_apc_info <- function(df, apc_field) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    if (is.list(df$apc_list[i]) && length(df$apc_list[i]) > 0 && 
        apc_field %in% names(df$apc_list[i])) {
      result[i] <- as.character(df$apc_list[i][[apc_field]])
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Extract journal name
extract_journal_name <- function(df) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    hv <- df$host_venue[i]
    if (is.list(hv) && length(hv) > 0 && "display_name" %in% names(hv)) {
      result[i] <- hv$display_name
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Extract journal ISSN
extract_journal_issn <- function(df) {
  result <- vector("character", nrow(df))
  for (i in 1:nrow(df)) {
    hv <- df$host_venue[i]
    if (is.list(hv) && length(hv) > 0 && "issn" %in% names(hv) && 
        is.list(hv$issn) && length(hv$issn) > 0) {
      result[i] <- paste(hv$issn, collapse = "; ")
    } else {
      result[i] <- NA
    }
  }
  return(result)
}

# Process the complex nested data columns first
processed_df <- springer_works %>%
  mutate(
    first_author = extract_first_author(springer_works),
    all_authors = extract_all_authors(springer_works),
    corresponding_authors = extract_corresponding_authors(springer_works),
    journal_name = extract_journal_name(springer_works),
    journal_issn = extract_journal_issn(springer_works),
    apc_value = extract_apc_info(springer_works, "value"),
    apc_currency = extract_apc_info(springer_works, "currency"),
    apc_value_usd = extract_apc_info(springer_works, "value_usd"),
    `Corresponding Y/N` = "Y"
  )

# Create a new dataframe that can be exported to Excel
# Start with non-list columns
export_df <- processed_df %>%
  select_if(~ !is.list(.))  # Remove list columns that can't be exported directly

# Process any remaining list columns by converting them to text
list_columns <- names(processed_df)[sapply(processed_df, is.list)]
cat("Converting complex list columns to text format:", length(list_columns), "columns\n")

for (col in list_columns) {
  # Convert list column to string representation
  export_df[[col]] <- sapply(processed_df[[col]], function(x) {
    if (is.null(x) || length(x) == 0) {
      return(NA_character_)
    } else {
      # Try to convert to a simple string representation
      tryCatch({
        if (is.character(x)) {
          return(paste(x, collapse = "; "))
        } else {
          return(paste(capture.output(str(x)), collapse = " "))
        }
      }, error = function(e) {
        return("Complex data")
      })
    }
  })
}

# Add any columns that might have been missed
all_columns <- union(colnames(export_df), colnames(processed_df))
for (col in all_columns) {
  if (!col %in% colnames(export_df) && !is.list(processed_df[[col]])) {
    export_df[[col]] <- processed_df[[col]]
  }
}

# Print information about what's being exported
cat("Preparing to export", ncol(export_df), "columns out of", ncol(processed_df), "total columns\n")

# Create a function to truncate text columns to Excel's limit
truncate_for_excel <- function(df, max_chars = 32000) {
  for (col in colnames(df)) {
    if (is.character(df[[col]])) {
      # Check if any cell exceeds the limit
      if (any(nchar(df[[col]], keepNA = FALSE) > max_chars, na.rm = TRUE)) {
        cat("Truncating column", col, "to fit Excel's character limit\n")
        # Truncate and add indicator
        df[[col]] <- sapply(df[[col]], function(x) {
          if (is.na(x) || nchar(x) <= max_chars) {
            return(x)
          } else {
            return(paste0(substr(x, 1, max_chars - 15), " [TRUNCATED]"))
          }
        })
      }
    }
  }
  return(df)
}

# Truncate all text columns in the dataframe to fit Excel's limits
export_df_truncated <- truncate_for_excel(export_df)

# Export the truncated dataframe to Excel
write_xlsx(export_df_truncated, "allapcinfo_springer_works_all_columns.xlsx")
cat("Successfully exported all columns with automatic truncation for Excel compatibility\n")

# Also save a condensed version with key columns for easier viewing
selected_columns <- c(
  "id", "title", "display_name", "first_author", "all_authors", "corresponding_authors",
  "journal_name", "journal_issn", "publication_date", "publication_year", "doi", 
  "type", "cited_by_count", "is_open_access", "open_access_status", 
  "apc_value", "apc_currency", "apc_value_usd", "Corresponding Y/N"
)

# Filter for columns that actually exist in our data
selected_columns <- selected_columns[selected_columns %in% colnames(export_df_truncated)]

# Create a condensed version with key columns
springer_export_condensed <- export_df_truncated %>%
  select(all_of(selected_columns))

# Export the condensed version
write_xlsx(springer_export_condensed, "allapcinfo_springer_works_key_columns.xlsx")
cat("Exported condensed version with", length(selected_columns), "key columns\n")

# Optionally, export very large text fields to separate text files
large_text_columns <- names(which(sapply(export_df, function(col) {
  if (is.character(col)) {
    any(nchar(col, keepNA = FALSE) > 30000, na.rm = TRUE)
  } else {
    FALSE
  }
})))

if (length(large_text_columns) > 0) {
  cat("Exporting very large text columns to separate text files:", 
      paste(large_text_columns, collapse = ", "), "\n")
  
  dir.create("large_text_fields", showWarnings = FALSE)
  
  for (col in large_text_columns) {
    for (i in 1:nrow(export_df)) {
      text <- export_df[[col]][i]
      if (!is.na(text) && nchar(text) > 30000) {
        # Create a filename based on the row ID and column name
        filename <- paste0("large_text_fields/row", i, "_", col, ".txt")
        # Write the full text to a file
        writeLines(text, filename)
      }
    }
  }
}

cat("Data export complete!\n")