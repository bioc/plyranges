# test-nearest.R
context("nearest/follows/precedes")

test_that("nearest/follows/precedes matches IRanges methods", {

  ##      ..
  ##           ..
  ## ..
  ##             ..
  ##                  ..
  ## xxxx
  ##  xxx
  ##         xx
  ##               xx
  ##               xxx

  query <- IRanges(c(6, 11, 1, 13, 18), width=c(2, 2, 2, 2, 2))
  subject <- IRanges(c(1, 2, 9, 15, 15), width=c(4, 3, 2, 2, 3))

  result <- join_nearest(query, subject)
  expect_identical(mcols(result)$nearest,
                  subject[nearest(query, subject, select = "arbitrary")])
  # left/right joins select all nearest hits
  left <- join_nearest_left(query, subject)
  expect_identical(mcols(left)$nearest, subject[c(1,2,3,5)])
  right <- join_nearest_right(query, subject)
  expect_identical(mcols(right)$nearest, subject[c(3,2,4,5)])

  # follows --
  fol1 <- join_follow(query, subject)
  expect_identical(mcols(fol1)$follows, subject[c(2,3,3,5)])
  # all ranges that follow on the left
  fol2 <- join_follow_left(query, subject)
  expect_identical(mcols(fol2)$follows, subject[c(1,2,3,3,5)])

  # precedes --
  pre1 <- join_precede(query, subject)
  expect_identical(ranges(pre1), query[1:4])
  pre2 <- join_precede_right(query, subject)
  expect_identical(ranges(pre2), query[c(1,2,2,3,4,4)])

})

test_that("nearest/follows/precedes matches GenomicRanges", {
  query_ir <- IRanges(c(6, 11, 1, 13, 18), width=c(2, 2, 2, 2, 2))
  subject_ir <- IRanges(c(1, 2, 9, 15, 15), width=c(4, 3, 2, 2, 3))

  #+#      ..
  #*#           ..
  #-# ..
  #+#             ..
  #-#                  ..
  #-# xxxx
  #+#  xxx
  #+#         xx
  #-#               xx
  #+#               xxx
  query_gr <- GRanges(seqnames = "chr1", ranges = query_ir,
                      strand = c("+", "*", "-", "+", "-"))
  subject_gr <- GRanges(seqnames = "chr1", ranges = subject_ir,
                        strand = c("-", "+", "+", "-", "-"))
  # upstream/downstream
  up <- join_nearest_upstream(query_gr, subject_gr)
  expect_identical(mcols(up)$nearest, subject_gr[c(3)])

  down <- join_nearest_downstream(query_gr, subject_gr)
  expect_identical(mcols(down)$nearest, subject_gr[c(3,1,5)])

  # keeps no strand calls, plus gives all follows
  follow_up <- join_follow_upstream(query_gr, subject_gr)
  expect_identical(mcols(follow_up)$follows, subject_gr[c(2,3,4,5,4,5,3)])

  precede_down <- join_precede_downstream(query_gr, subject_gr)
  expect_identical(mcols(precede_down)$precedes, subject_gr[c(3,1,5)])
  # nearest/follows/precedes ignores strandedness so should be identical to
  # ranges analogues
  nearest_gr <- join_nearest(query_gr, subject_gr)
  nearest_ir <- join_nearest(query_ir, subject_ir)
  expect_identical(ranges(nearest_ir), ranges(nearest_gr))
  expect_identical(mcols(nearest_ir)$nearest, ranges(nearest_gr$nearest))

  follows_gr <- join_follow(query_gr, subject_gr)
  follows_ir <- join_follow(query_ir, subject_ir)
  expect_identical(ranges(follows_ir), ranges(follows_gr))
  expect_identical(mcols(follows_ir)$follows, ranges(follows_gr$follows))

  precedes_gr <- join_precede(query_gr, subject_gr)
  precedes_ir <- join_precede(query_ir, subject_ir)
  expect_identical(ranges(precedes_ir), ranges(precedes_gr))
  expect_identical(mcols(precedes_ir)$precedes, ranges(precedes_gr$precedes))


})
