
include { get_input_cells } from "${projectDir}/modules/cellbender/get_input_cells.nf"
include { remove_background } from "${projectDir}/modules/cellbender/remove_background.nf"
include { remove_background__qc_plots } from "${projectDir}/modules/cellbender/remove_background__qc_plots.nf"
include { remove_background__qc_plots_2 } from "${projectDir}/modules/cellbender/remove_background__qc_plots_2.nf"
include { preprocess_output } from "${projectDir}/modules/cellbender/preprocess_output.nf"

workflow cellbender_workflow {
    take:
    ch_experimentid_paths10x_raw      // sample, path to cellranger raw_feature_bc_matrix folder

    ch_experimentid_paths10x_filtered // sample,                    filtered_feature_bc_matrix

    channel__file_paths_10x           // sample, raw_feature_bc_matrix/barcodes.tsv.gz,
                                      //         raw_feature_bc_matrix/features.tsv.gz,
                                      //         raw_feature_bc_matrix/matrix.mtx.gz

    ncells_cellranger                 // sample, cellranger n cells or '0'

    sample_tirectum_cellbenderparams  // sample, all cellbender params 1 ... n  
//	tuple(sample, //0
//	      biopsy_type, //1
//	      expected_nemptydroplets_umi_cutoff, //2
//	      method_estimate_ncells,//3
//	      lower_bound_umis_estimate_ncells,//4
//	      method_estimate_nemptydroplets,//5
//	      lower_bound_umis_estimate_nemptydroplets,//6
//	      upper_bound_umis_estimate_nemptydroplets,//7
//	      estimate_nemptydroplets_umi_add_factor,//8
//	      estimate_nemptydroplets_subtract_cell_factor,//9
//	      estimate_nemptydroplets_min_drop,//10
//	      epochs,//11
//	      learning_rate,//12
//	      zdim,//13
//	      zlayers,//14
//	      low_count_threshold,//15
//	      fpr) }//16
    
    main:
    
    get_input_cells(
	channel__file_paths_10x
            .join(ncells_cellranger) 
            .join(sample_tirectum_cellbenderparams
		  .map {sample, biopsy_type,
			expected_nemptydroplets_umi_cutoff, //2
			method_estimate_ncells,//3
			lower_bound_umis_estimate_ncells,//4
			method_estimate_nemptydroplets,//5
			lower_bound_umis_estimate_nemptydroplets,//6
			upper_bound_umis_estimate_nemptydroplets,//7
			estimate_nemptydroplets_umi_add_factor,//8
			estimate_nemptydroplets_subtract_cell_factor,//9
			estimate_nemptydroplets_min_drop,//10
			epochs,//11
			learning_rate,//12
			zdim,//13
			zlayers,//14
			low_count_threshold,//15
			fpr //16
			-> tuple(sample, biopsy_type,
				 method_estimate_ncells,
				 expected_nemptydroplets_umi_cutoff,
				 method_estimate_ncells,
				 lower_bound_umis_estimate_ncells,
				 method_estimate_nemptydroplets,
				 lower_bound_umis_estimate_nemptydroplets,
				 upper_bound_umis_estimate_nemptydroplets,
				 estimate_nemptydroplets_umi_add_factor,
				 estimate_nemptydroplets_subtract_cell_factor,
				 estimate_nemptydroplets_min_drop)}))

//  // Correct counts matrix to remove ambient RNA
    remove_background(
        get_input_cells.out.cb_input
            .join(sample_tirectum_cellbenderparams
		  .map {sample, biopsy_type,
			expected_nemptydroplets_umi_cutoff, //2
			method_estimate_ncells,//3
			lower_bound_umis_estimate_ncells,//4
			method_estimate_nemptydroplets,//5
			lower_bound_umis_estimate_nemptydroplets,//6
			upper_bound_umis_estimate_nemptydroplets,//7
			estimate_nemptydroplets_umi_add_factor,//8
			estimate_nemptydroplets_subtract_cell_factor,//9
			estimate_nemptydroplets_min_drop,//10
			epochs,//11
			learning_rate,//12
			zdim,//13
			zlayers,//14
			low_count_threshold,//15
			fpr //16
			-> tuple(sample, biopsy_type,
				 epochs,
				 learning_rate,
				 zdim,
				 zlayers,
				 low_count_threshold,
				 fpr)}))
    

    preprocess_output(remove_background.out.experimentid_cellbender_to_preprocess)

    // Make some basic plots
    remove_background__qc_plots(
        preprocess_output.out.experiment_id_cb_plot_input)

    // Make secondary set of QC plots, comparing cellbender and cellranger filtered outputs
    remove_background__qc_plots_2(
	preprocess_output.out.qc_plots_2
            .combine(ch_experimentid_paths10x_raw, by: 0)
            .combine(ch_experimentid_paths10x_filtered, by: 0))
    
    
    emit:
    filt10x = preprocess_output.out.filt10x
    custom_qc_pipeline_input = preprocess_output.out.custom_qc_pipeline_input
}

