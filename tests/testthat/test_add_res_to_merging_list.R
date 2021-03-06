# Test for add.res.to.merging.list, using sample data in vignette
test_that("merging EWCE results from multiple sets", {
    # load vignette data
    # Load some vignette data
    tt_alzh <- tt_alzh()
    tt_alzh_BA36 <- tt_alzh_BA36()
    tt_alzh_BA44 <- tt_alzh_BA44()
    ctd <- ctd()

    # Run EWCE analysis
    tt_results <- ewce_expression_data(
        sct_data = ctd, tt = tt_alzh, annotLevel = 1,
        ttSpecies = "human", sctSpecies = "mouse"
    )
    tt_results_36 <- ewce_expression_data(
        sct_data = ctd, tt = tt_alzh_BA36,
        annotLevel = 1, ttSpecies = "human",
        sctSpecies = "mouse"
    )
    tt_results_44 <- ewce_expression_data(
        sct_data = ctd, tt = tt_alzh_BA44,
        annotLevel = 1, ttSpecies = "human",
        sctSpecies = "mouse"
    )
    # Fill a list with the results
    results <- add.res.to.merging.list(tt_results)
    results <- add.res.to.merging.list(tt_results_36, results)
    results <- add.res.to.merging.list(tt_results_44, results)

    # check some non-directional tests
    tt_results_adj <- tt_results[c(1, 2, 4)]
    names(tt_results_adj) <- c("joint_results", "hit.cells", "bootstrap_data")
    # run the undirectional
    results_adj <- add.res.to.merging.list(tt_results_adj)
    # should get error if try to combine directional with undirectional
    error_return <-
        tryCatch(add.res.to.merging.list(tt_results_36, results_adj),
            error = function(e) e,
            warning = function(w) w
        )

    # check returns
    test1 <- length(results) == 6
    # make sure all metrics returned for each
    test2 <- all.equal(
        unlist(lapply(results, function(x) names(x))),
        rep(c("Direction", "bootstrap_data", "hitCells"), 6)
    )
    # check output equal to input before combination
    test3 <- all.equal(results[[1]]$hitCells, tt_results$hit.cells.up)
    test4 <- all.equal(results[[5]]$hitCells, tt_results_44$hit.cells.up)
    test5 <- all.equal(tt_results_36$bootstrap_data.up, results[[3]]$bootstrap_data)

    # Perform the merged analysis
    merged_res <- merged_ewce(results, reps = 10) # <- For publication reps should be higher

    ewce_plot_res <- ewce.plot(merged_res)$plain
    # fail if any but ggplot returned
    test6 <- is(ewce_plot_res)[1] == "gg"


    # undirectional tests
    test7 <- length(results_adj[[1]]) == 2
    test8 <- is(error_return, "error")

    # fail if any subtest isn't true
    expect_equal(all(test1, test2, test3, test4, test5, test6, test7, test8), TRUE)
})
