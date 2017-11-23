# ranges-reduce
#' @importFrom S4Vectors rbind.DataFrame
reduce_rng <- function(.data, reduced, ...) {

  dots <- UQS(...)

  revmap <- mcols(reduced)$revmap

  ranges_list <- relist(.data[unlist(revmap)], revmap)

  reduced_summary <- as(lapply(ranges_list, summarize_rng, dots), "List")

  mcols(reduced) <- Reduce(rbind.DataFrame, reduced_summary)
  return(reduced)
}

#' Reduce then aggregate a Ranges object
#'
#' @param .data a Ranges object to reduce
#' @param ... Name-value pairs of summary functions.
#'
#' @return a Ranges object with the
#' @rdname ranges-reduce
#' @importFrom IRanges reduce
#' @importFrom S4Vectors rbind.DataFrame
#' @importFrom utils relist
#' @examples
#' df <- data.frame(start = 1:10, width = 5,  seqnames = "seq1",
#' strand = sample(c("+", "-", "*"), 10, replace = TRUE), gc = runif(10))
#' rng <- Ranges(df)
#' rng %>% reduce_ranges()
#' rng %>% reduce_ranges(gc = mean(gc))
#' rng %>% reduce_ranges_directed(gc = mean(gc))
#' @export
reduce_ranges <- function(.data, ...) { UseMethod("reduce_ranges") }

#' @method reduce_ranges Ranges
#' @export
reduce_ranges.Ranges <- function(.data, ...) {
  dots <- quos(...)
  if (length(dots) == 0L) {
    return(reduce(.data))
  }

  reduced <- reduce(.data, with.revmap = TRUE)

  reduce_rng(.data, reduced, dots)

}

#' @method reduce_ranges GenomicRanges
#' @export
reduce_ranges.GenomicRanges <- function(.data, ...) {

  dots <- quos(...)
  if (length(dots) == 0L) {
    return(reduce(.data,ignore.strand = TRUE))
  }

  reduced <- reduce(.data, with.revmap = TRUE, ignore.strand = TRUE)
  reduce_rng(.data, reduced, dots)
}

#' @rdname ranges-reduce
#' @export
reduce_ranges_directed <- function(.data, ...) {
  UseMethod("reduce_ranges_directed")
}

#' @importFrom IRanges reduce
#' @method reduce_ranges_directed GenomicRanges
#' @export
reduce_ranges_directed.GenomicRanges <- function(.data, ...) {

  dots <- quos(...)
  if (length(dots) == 0L) {
    return(reduce(.data,ignore.strand = FALSE))
  }

  reduced <- reduce(.data, with.revmap = TRUE, ignore.strand = FALSE)
  reduce_rng(.data, reduced, dots)

}

